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
import "helper/yt.js" as YT


//Dialog {
//    id: searchYTDialog
//    allowedOrientations: Orientation.All
//    canAccept: searchTerm.text !== ""
//    acceptDestination: searchResults
//    property QtObject dataContainer

//    DialogHeader {
//        acceptText: "Search on Youtube"
//    }

//    TextField {
//        id: searchTerm
//        placeholderText: "Type in search term here"
//        anchors.centerIn: parent
//        width: Screen.width - 20
//        focus: true
//    }
//    Keys.onEnterPressed: accept();
//    Keys.onReturnPressed: accept();

//    onAcceptPendingChanged: {
//        if (acceptPending) {
//            // Tell the destination page what the search term is
//            acceptDestinationInstance.searchTerm = searchTerm.text
//        }
//    }

//    Component {
//        id: searchResults

        Page {
            id: searchResultsDialog
            property string searchTerm
            allowedOrientations: Orientation.All
            backNavigation: false
            property QtObject dataContainer
            property string streamUrl
            property bool ytDetect: true
            property string websiteUrl: "http://m.youtube.com/"
            property string searchUrl: "http://m.youtube.com/results?q="
            property string uA: "Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"


            SilicaWebView {
                id: ytView
                anchors.centerIn: parent
                // Width and height for scale=2.0
//                width: searchResultsDialog.orientation === Orientation.Portrait ? Screen.width / 2 : (Screen.height - 100) / 2
//                height: Screen.height / 2
                anchors.fill: parent
                overridePageStackNavigation: true
                focus: true

                PullDownMenu {
                    MenuItem {
                        text: "Go Back"
                        onClicked: pageStack.pop();
                    }
                }


                header: Row {
                    width: parent.width
                    spacing: 1
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Switch {
                        id: backBtn
                        onCheckedChanged: { pageStack.pop() }
                    }
                    SearchField {
                        id: searchField
                        property string acceptedInput: ""
                        width: parent.width - backBtn.width

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
                            ytView.url = searchUrl + acceptedInput
                            searchField.focus = false
                        }
                    }
                }

                //scale: 2.0  // there seems no way to set the default text size and the default one is too tiny so scale instead
                //url: "http://ytapi.com/search/?vq=" + searchTerm  // now that we have youtube => ytapi openurl action we can use the official youtube site ;)
                //url: "http://m.youtube.com/" // results?q=" + searchTerm
                // iPhone user agent popups for app installation
                //experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
                experimental.userAgent: uA
                experimental.preferences.minimumFontSize: 14

                onNavigationRequested: {
                    //console.debug("[SecondPage.qml] Request navigation to " + request.url)
                    if (YT.checkYoutube(request.url.toString()) === true && ytDetect === true) {
                        //console.debug("[SecondPage.qml] Youtube Link detected")
                        request.action = WebView.IgnoreRequest;
                        dataContainer.isYtUrl = true;
                        var yturl = YT.getYoutubeVid(request.url.toString());
                        //YT.getYoutubeTitle(url.toString());
                        if (dataContainer != null) {
                            if (!dataContainer.youtubeDirect) dataContainer.streamUrl = yturl;
                            else dataContainer.originalUrl = request.url
                            pageStack.push(dataContainer);
                        }
                    }
                    else {
                        request.action = WebView.AcceptRequest;
                    }
                }


//                onUrlChanged: {
//                    //console.debug("New url:" +url)
//                    if (YT.checkYoutube(url.toString()) === true) {
//                        dataContainer.isYtUrl = true;
//                        var yturl = YT.getYoutubeVid(url.toString());
//                        //YT.getYoutubeTitle(url.toString());
//                        if (dataContainer != null) {
//                            if (!dataContainer.youtubeDirect) dataContainer.streamUrl = yturl;
//                            else dataContainer.originalUrl = url
//                            ytView.goBack();
//                            pageStack.push(dataContainer);
//                        }
//                    }
//                }

                VerticalScrollDecorator {}

                Component.onCompleted: url = websiteUrl
            }
       }

   // }
//}





