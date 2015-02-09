/*
  Copyright (C) 2013 Leszek Lesner.
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
import QtMultimedia 5.0
import Sailfish.Pickers 1.0
import "helper"
import "fileman"

Page {
    id: page
    allowedOrientations: Orientation.All


    signal updateCover
    signal removeFile(string url)

    // Settings /////////////////////////////////////////
    property string openDialogType: "adv"
    property bool enableSubtitles: true
    property int subtitlesSize: 25
    property bool boldSubtitles: false
    property string subtitlesColor: Theme.highlightColor
    property bool liveView: true
    /////////////////////////////////////////////////////

    // Videoplayer properties //////////////////////////
    property string originalUrl
    property string streamUrl
    property bool isYtUrl: false
    property bool youtubeDirect: true
    property bool autoplay: false
    property string streamTitle
    property string url720p
    property string url480p
    property string url360p
    property string url240p
    property string ytQual
    ////////////////////////////////////////////////////

    // Aliase
    property alias videoPickerComponent: videoPickerComponent
    property alias openFileComponent: openFileComponent

    Component.onCompleted: {
        // Initialize the database
        DB.initialize();
        DB.getHistory();
    }

    onStreamTitleChanged: {
        console.debug("[firstPage.qml] streamTitle: " + streamTitle)
    }

    function loadPlayer() {
        pageStack.push(Qt.resolvedUrl("videoPlayer.qml"), {dataContainer: page});
    }

    function addHistory(url) {
        //console.debug("Adding " + url);
        historyModel.append({"hurl": url});
    }

    ListModel {
        id: historyModel
    }

    Keys.onEnterPressed: {
        if (urlField.text != "" && urlField.visible) loadPlayer();
    }
    Keys.onReturnPressed: {
        if (urlField.text != "" && urlField.visible) loadPlayer();
    }

    Component  {
        id: videoPickerComponent
        VideoPickerPage {
            //: For choosing video to open from the device
            //% "Open video"
            title: qsTr("Open Video")
            Component.onDestruction: {
                //console.debug("[OpenURLPage.qml]: Selected Video: " + selectedContent);
                mainWindow.firstPage.loadPlayer();
                mainWindow.firstPage.originalUrl = selectedContent;
                mainWindow.firstPage.streamUrl = selectedContent;
            }
        }
    }

    Component {
        id: openFileComponent
        OpenDialog {
            onOpenFile: {
                mainWindow.firstPage.originalUrl = path;
                mainWindow.firstPage.streamUrl = path;
                mainWindow.firstPage.loadPlayer();
            }
        }
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent

        PullDownMenu {
            id: pulley
            MenuItem {
                text: "About "+ appname
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
            }
            MenuItem {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
            }
        }

        PageHeader {
            id: pageHeader
            title: {
                if (urlField.visible) ""
                else if (drawer.opened) qsTr("History")
                else qsTr("Open")
            }
            TextField {
                id: urlField
                visible: false
                placeholderText: qsTr("Type in URL here")
                label: qsTr("URL to media")
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: Theme.paddingLarge
                width: Screen.width - Theme.paddingLarge
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoPredictiveText
                EnterKey.enabled: text.length > 0
                EnterKey.text: qsTr("Open")
                Component.onCompleted: {
                    // console.debug("StreamUrl :" + streamUrl) // DEBUG
                    if (streamUrl !== "") {
                        text = streamUrl;
                        selectAll();
                    }
                }
            }
        }


        Drawer {
            id: drawer

            width: parent.width
            height: parent.height - pageHeader.height
            anchors.bottom: parent.bottom
            anchors.top: pageHeader.bottom
            //anchors.fill: parent

            dock: page.isPortrait ? Dock.Top : Dock.Left

            background: SilicaListView {
                anchors.fill: parent
                model: historyModel

                // Not necessary now. Later maybe removing all history
                //            PullDownMenu {
                //                MenuItem {
                //                    text: "Option 1"
                //                }
                //                MenuItem {
                //                    text: "Option 2"
                //                }
                //            }
                VerticalScrollDecorator {}

                delegate: ListItem {
                    id: listItem

                    Label {
                        x: Theme.paddingLarge
                        text: hurl
                        anchors.verticalCenter: parent.verticalCenter
                        color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    onClicked: {
//                        urlField.text = hurl
//                        drawer.open = !drawer.open
                        streamUrl = hurl
                        loadPlayer();
                        //openUrlPage.loadUrl(); // No autoload for the moment. TODO: Maybe a thing for global settings
                    }
                }
            }

            MouseArea {
                enabled: drawer.open
                anchors.fill: column
                onClicked: drawer.open = false
            }

            Item {
                id: column
                anchors.fill: parent

                ItemButton {
                    id: historyBtn
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width / 2
                    height: width
                    text: qsTr("History")
                    onClicked: {
                        //DB.getHistory();
                        drawer.open = !drawer.open
                    }
                    color: "gray"
                    icon: Qt.resolvedUrl("images/icon-l-backup.png")
                }

                ItemButton {
                    id: bookmarksBtn
                    anchors.top: parent.top
                    anchors.right: parent.right
                    width: parent.width / 2
                    height: width
                    text: qsTr("Bookmarks")
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("BookmarksPage.qml"), {dataContainer: page, modelBookmarks: mainWindow.modelBookmarks});
                    }
                    color: "brown"
                    icon: Qt.resolvedUrl("images/icon-l-star.png")
                }

                ItemButton {
                    id: youtubeBtn
                    anchors.left: parent.left
                    anchors.top: historyBtn.bottom
                    width: parent.width / 2
                    height: width
                    text: qsTr("Search on Youtube")
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("SecondPage.qml"), {dataContainer: page});
                    }
                    color: "red"
                    icon: Qt.resolvedUrl("images/icon-l-service-youtube.png")
                }

                ItemButton {
                    id: openFileBtn
                    anchors.top: bookmarksBtn.bottom
                    anchors.right: parent.right
                    text: qsTr("Browse Files")
                    visible: true
                    width: parent.width / 2
                    height: width
                    onClicked: {
                        if (mainWindow.firstPage.openDialogType === "adv") pageStack.push(Qt.resolvedUrl("fileman/Main.qml"), {dataContainer: mainWindow.firstPage});
                        else if (mainWindow.firstPage.openDialogType === "gallery") pageStack.push(mainWindow.firstPage.videoPickerComponent);
                        else if (mainWindow.firstPage.openDialogType === "simple") pageStack.push(mainWindow.firstPage.openFileComponent);
                    }
                    color: "blue"
                    icon: Qt.resolvedUrl("images/icon-l-media-files.png")
                }

                ItemButton {
                    id: openUrlBtn
                    anchors.left: parent.left
                    anchors.top: youtubeBtn.bottom
                    width: parent.width / 2
                    height: width
                    text: qsTr("Enter URL")
                    onClicked: {
                        urlField.visible = !urlField.visible
                        if (urlField.visible) urlField.forceActiveFocus()
                    }
                    color: "green"
                    icon: Qt.resolvedUrl("images/icon-l-redirect.png")
                }

//                TextField {
//                    id: urlField
//                    placeholderText: "Type in URL here"
//                    anchors.top: openFileBtn.bottom
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    width: Screen.width - 20
//                    focus: true
//                    Component.onCompleted: {
//                        // console.debug("StreamUrl :" + streamUrl) // DEBUG
//                        if (streamUrl !== "") {
//                            text = streamUrl;
//                            selectAll();
//                        }
//                    }
//                }

//                Button {
//                    id: addToBookmarkBtn
//                    anchors.top: historyBtn.bottom
//                    anchors.topMargin: 15
//                    //anchors.right: historyBtn.right
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    text: "Add to bookmarks"
//                    visible: {
//                        if (urlField.text !== "") return true
//                        else return false
//                    }
//                    onClicked: {
//                        pageStack.push(Qt.resolvedUrl("AddBookmark.qml"), { bookmarks: mainWindow.modelBookmarks, editBookmark: false, bookmarkUrl: urlField.text });
//                    }
//                }
            }

        }
    }


}


