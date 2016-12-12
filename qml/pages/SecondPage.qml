/*
  Copyright (C) 2013 Leszek Lesner
  Contact: Leszek Lesner <leszek.lesner@web.de>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import QtMultimedia 5.0
import "helper/yt.js" as YT
import "helper"


Page {
    id: searchResultsDialog
    property string searchTerm
    allowedOrientations: Orientation.All
    backNavigation: true
    property QtObject dataContainer
    property string streamUrl
    property bool ytDetect: true
    property string websiteUrl: "https://m.youtube.com/"
    property string searchUrl: "https://m.youtube.com/results?q="
    property string uA: "Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"

    onStateChanged: {
        if (status == PageStatus.Active) ytView.experimental.page.visible = true
        else ytView.experimental.page.visible = false
    }

    SilicaWebView {
        id: ytView
        anchors.centerIn: parent
        // Width and height for scale=2.0
        //                width: searchResultsDialog.orientation === Orientation.Portrait ? Screen.width / 2 : (Screen.height - 100) / 2
        //                height: Screen.height / 2
        anchors.fill: parent
        overridePageStackNavigation: true
        focus: true

        property variant itemSelectorIndex: -1

        experimental.itemSelector: PopOver {}

        PullDownMenu {
            MenuItem {
                text: "Go Back"
                onClicked: pageStack.pop();
            }
        }

        Rectangle {
            id: loadingRec
            height: Theme.iconSizeExtraSmall / 2
            color: Theme.highlightColor
            anchors.top: parent.top
            property int minimumValue: 0
            property int maximumValue: 100
            property int value: ytView.loadProgress
            width: (value / (maximumValue - minimumValue)) * parent.width
            visible: value == 100 ? false : true
        }

        header: Row {
            width: parent.width
            spacing: 1
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            SearchField {
                id: searchField
                property string acceptedInput: ""
                width: parent.width

                placeholderText: "Search.."
                //                        anchors.top: parent.top
                //                        anchors.left: parent.left
                //                        anchors.right: parent.right

                EnterKey.enabled: text.trim().length > 0
                EnterKey.text: "Go!"

                Component.onCompleted: {
                    acceptedInput = ""
                    _editor.accepted.connect(searchEntered)
                }

                // is called when user presses the Return key
                function searchEntered() {
                    searchField.acceptedInput = text
                    ytView.url = searchUrl + encodeURI(acceptedInput)
                    searchField.focus = false
                }
            }
        }
        experimental.userAgent: uA
        experimental.preferences.minimumFontSize: 11
        experimental.userScripts: [Qt.resolvedUrl("helper/userscript.js")]
        experimental.preferences.navigatorQtObjectEnabled: true

        experimental.onMessageReceived: {
            //console.log('onMessageReceived: ' + message.data );
            var data = null
            try {
                data = JSON.parse(message.data)
            } catch (error) {
                console.log('onMessageReceived: ' + message.data );
                return
            }
            if (data.href != "" && data.href != "CANT FIND LINK") {
                contextMenu.clickedUrl = data.href
                contextMenu.show()
            }
        }



        onNavigationRequested: {
            //console.debug("[SecondPage.qml] Request navigation to " + request.url)
            if (YT.checkYoutube(request.url.toString()) === true && ytDetect === true) {
                if (YT.getYtID(request.url.toString()) != "") {
                    //console.debug("[SecondPage.qml] Youtube Link detected")
                    request.action = WebView.IgnoreRequest;
                    dataContainer.isYtUrl = true;
                    //var yturl = YT.getYoutubeVid(request.url.toString());
                    //YT.getYoutubeTitle(url.toString());
                    if (dataContainer != null) {
                        dataContainer.streamUrl = request.url;
                        dataContainer.originalUrl = request.url
                        dataContainer.loadPlayer();
                    }
                    ytView.reload(); // WTF why is this working with IgnoreRequest

                } else { request.action = WebView.AcceptRequest; }
            }
            else {
                request.action = WebView.AcceptRequest;
            }
        }

        VerticalScrollDecorator {}

        Component.onCompleted: url = websiteUrl
    }

    DockedPanel {
        id: navbar

        width: parent.width
        height: Theme.itemSizeSmall + Theme.paddingSmall

        dock: Dock.Bottom
        open: ytView.canGoBack && (!ytView.atYEnd)

        Rectangle {
            anchors.fill: parent
            color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
        }

        Row {
            anchors.centerIn: parent
            IconButton {
                id: backBtn
                icon.source: "image://theme/icon-m-back"
                enabled: ytView.canGoBack
                visible: ytView.canGoBack
                anchors.centerIn: parent
                onClicked: {
                    ytView.goBack();
                }
            }
        }
    }

    // Modal works not so great so use or own here
    Rectangle {
        color: "black"
        opacity: 0.60
        anchors.fill: parent
        visible: contextMenu.open
        MouseArea {
            anchors.fill: parent
            onClicked: contextMenu.hide();
        }
    }

    DockedPanel {
        id: contextMenu

        width: parent.width
        height: contextButtons.height + Theme.paddingLarge * 2

        dock: Dock.Bottom
        //modal: true

        Rectangle {
            anchors.fill: parent
            color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
        }

        property string clickedUrl

        Column {
            id: contextButtons
            anchors.centerIn: parent
            spacing: Theme.paddingMedium
            Button {
                id: widestBtn
                text: qsTr("Load with ytdl")
                onClicked: {
                    contextMenu.hide()
                    _ytdl.setUrl(contextMenu.clickedUrl)
                    _ytdl.setParameter("-f best") // Try to get best format usually non dash format
                    _ytdl.getStreamUrl()
                    _ytdl.getStreamTitle()
                    mainWindow.firstPage.isYtUrl = false
                    mainWindow.firstPage.busy.visible = true;
                    mainWindow.firstPage.busy.running = true;
                }
                visible: contextMenu.clickedUrl != ""
            }
            Button {
                text: qsTr("Load")
                width: widestBtn.width
                onClicked: {
                    contextMenu.hide()
                    dataContainer.isYtUrl = true;
                    //var yturl = YT.getYoutubeVid(request.url.toString());
                    //YT.getYoutubeTitle(url.toString());
                    if (dataContainer != null) {
                        dataContainer.streamUrl = contextMenu.clickedUrl
                        dataContainer.originalUrl = contextMenu.clickedUrl
                        dataContainer.loadPlayer();
                    }
                }
                visible: contextMenu.clickedUrl != ""
            }
        }
    }
}





