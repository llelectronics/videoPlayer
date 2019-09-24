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
import "helper/db.js" as DB
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
    property string uA: "Mozilla/5.0 (Linux; Maemo; Android 2.3.5; U; Sailfish) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"

    function workaroundRefresh() {
        ytView.update();
        mainWindow.update();
        ytView.visible = false;
        ytView.update();
        ytView.visible = true;
        ytView.update();
    }

    Drawer {
        id: searchHistoryDrawer

        anchors.fill: parent

        dock: searchResultsDialog.isPortrait ? Dock.Top : Dock.Left
        property QtObject historyListView

        background: SilicaListView {
            id: searchView
            anchors.fill: parent
            model: mainWindow.firstPage.searchHistoryModel
            verticalLayoutDirection: ListView.BottomToTop

            VerticalScrollDecorator {}

            delegate: ListItem {
                id: listItem

                Label {
                    x: Theme.paddingLarge
                    text: searchTerm
                    anchors.verticalCenter: parent.verticalCenter
                    color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    ytView.searchField.text = searchTerm
                    ytView.url = searchUrl + encodeURI(searchTerm)
                    searchHistoryDrawer.open = false
                }
            }
            ViewPlaceholder {
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingLarge
                text: qsTr("No Search History")
                enabled: searchView.count == 0
            }
            Component.onCompleted: searchHistoryDrawer.historyListView = searchView
        }
        onOpenedChanged: {
            historyListView.scrollToTop();
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

            property int itemSelectorIndex: -1
            property QtObject searchField

            experimental.itemSelector: PopOver {}
            experimental.overview: true
            property variant devicePixelRatio: {//1.5
                if (Screen.width <= 540) return 1.5;
                else if (Screen.width > 540 && Screen.width <= 768) return 2.0;
                else if (Screen.width > 768) return 3.0;
            }
            experimental.customLayoutWidth: searchResultsDialog.width / devicePixelRatio

            PullDownMenu {
                MenuItem {
                    text : qsTr("Reload")
                    onClicked: ytView.reload();
                }
                MenuItem {
                    text: qsTr("History")
                    onClicked: searchHistoryDrawer.open = !searchHistoryDrawer.open
                    visible: ytDetect
                }
                MenuItem {
                    text: qsTr("Go Back")
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

                    placeholderText: qsTr("Search..")
                    //                        anchors.top: parent.top
                    //                        anchors.left: parent.left
                    //                        anchors.right: parent.right

                    EnterKey.enabled: text.trim().length > 0
                    EnterKey.text: "Go!"

                    Component.onCompleted: {
                        acceptedInput = ""
                        _editor.accepted.connect(searchEntered)
                        ytView.searchField = searchField
                    }

                    // is called when user presses the Return key
                    function searchEntered() {
                        searchField.acceptedInput = text
                        ytView.url = searchUrl + encodeURI(acceptedInput)
                        searchField.focus = false
                        DB.addSearchHistory(text)
                        mainWindow.firstPage.addSearchHistory(text)
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
                if (data.href !== "" && data.href !== "CANT FIND LINK") {
                    contextMenu.clickedUrl = data.href
                    contextMenu.show()
                }
            }

            onUrlChanged: {
                if (YT.checkYoutube(url.toString()) === true && ytDetect === true) {
                    if (YT.getYtID(url.toString()) !== "") {
                        if (dataContainer != null) {
                            if (dataContainer.alwaysYtdl) {
                                _ytdl.setUrl(url)
                                _ytdl.setParameter("-f " + dataContainer.ytdlQual)
                                _ytdl.getStreamUrl()
                                _ytdl.getStreamTitle()
                                dataContainer.isYtUrl = false
                                dataContainer.busy.visible = true;
                                dataContainer.busy.running = true;
                            }
                            else {
                                dataContainer.isYtUrl = true;
                                dataContainer.streamUrl = url;
                                dataContainer.originalUrl = url
                                dataContainer.isPlaylist = false;
                                dataContainer.isLiveStream = false;
                                dataContainer.loadPlayer();
                            }
                        }
                        ytView.goBack();
                    }
                }
            }

            onNavigationRequested: {
                request.action = WebView.IgnoreRequest;
                console.debug("[SecondPage.qml] Request navigation to " + request.url)
                if (ytDetect !== true) request.action = WebView.AcceptRequest;
//                if (YT.checkYoutube(request.url.toString()) === true && ytDetect === true) {
//                    if (YT.getYtID(request.url.toString()) !== "") {
//                        //console.debug("[SecondPage.qml] Youtube Link detected")
//                        request.action = WebView.IgnoreRequest;
//                        dataContainer.isYtUrl = true;
//                        //var yturl = YT.getYoutubeVid(request.url.toString());
//                        //YT.getYoutubeTitle(url.toString());
//                        if (dataContainer != null) {
//                            dataContainer.streamUrl = request.url;
//                            dataContainer.originalUrl = request.url
//                            dataContainer.isPlaylist = false;
//                            dataContainer.isLiveStream = false;
//                            dataContainer.loadPlayer();
//                        }
//                        ytView.reload(); // WTF why is this working with IgnoreRequest

//                    } else { request.action = WebView.AcceptRequest; }
//                }
//                else {
//                    request.action = WebView.AcceptRequest;
//                }
            }

            VerticalScrollDecorator {}

            Component.onCompleted: url = websiteUrl

            MouseArea {
                enabled: searchHistoryDrawer.open
                anchors.fill: parent
                onClicked: searchHistoryDrawer.open = false
            }
        } // Webview
    } // Drawer

    DockedPanel {
        id: navbar

        width: parent.width
        height: Theme.itemSizeSmall + Theme.paddingSmall

        dock: Dock.Bottom
        open: (!ytView.atYEnd) && (!searchHistoryDrawer.open)

        Rectangle {
            anchors.fill: parent
            color: Theme.overlayBackgroundColor
            opacity: 0.8
        }

        Row {
            anchors.centerIn: parent
            spacing: {
                if (backBtn.visible) (parent.width - 5*backBtn.width) / 6
                else (parent.width - 4*backBtn.width) / 5
            }
            IconButton {
                id: backBtn
                icon.source: "image://theme/icon-m-back"
                enabled: ytView.canGoBack
                visible: ytView.canGoBack
                onClicked: {
                    ytView.goBack();
                }
            }
            IconButton {
                id: homeBtn
                icon.source: "image://theme/icon-m-home";
                onClicked: {
                    ytView.url = "https://youtube.com"
                }
            }
            IconButton {
                id: libBtn
                icon.source: "image://theme/icon-m-levels"
                onClicked: {
                    ytView.url = "https://youtube.com/feed/subscriptions"
                }
            }
            IconButton {
                id: subBtn
                icon.source: "image://theme/icon-m-file-folder"
                onClicked: {
                    ytView.url = "https://youtube.com/feed/library"
                }
            }
//            IconButton {
//                id: reloadBtn
//                icon.source: ytView.loading ? "image://theme/icon-m-reset" : "image://theme/icon-m-refresh"
//                onClicked: {
//                    if (ytView.loading) ytView.stop();
//                    else ytView.reload();
//                }
//            }
            IconButton {
                id: searchBtn
                icon.source: "image://theme/icon-m-search"
                onClicked: {
                    ytView.scrollToTop();
                    ytView.searchField.forceActiveFocus();
                }
                onPressAndHold: {
                    ytView.scrollToTop();
                    searchHistoryDrawer.open = !searchHistoryDrawer.open
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
            color: Theme.overlayBackgroundColor
            opacity: 0.8
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
                    _ytdl.setParameter("-f " + mainWindow.firstPage.ytdlQual)
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
                        dataContainer.isPlaylist = false
                        dataContainer.isLiveStream = false
                        dataContainer.loadPlayer();
                    }
                }
                visible: contextMenu.clickedUrl != ""
            }
        }
    }
}





