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
    property string streamTitle
    property string url720p
    property string url480p
    property string url360p
    property string url240p
    property string ytQual

    Component.onCompleted: {
        // Initialize the database
        DB.initialize();
        DB.getHistory();
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

    Component  {
        id: videoPickerComponent
        VideoPickerPage {
            //: For choosing video to open from the device
            //% "Open video"
            title: qsTr("Open Video")
            Component.onDestruction: {
                //console.debug("[OpenURLPage.qml]: Selected Video: " + selectedContent);
                // TODO: Load videoPlayer function
                mainWindow.firstPage.originalUrl = selectedContent;
                mainWindow.firstPage.streamUrl = selectedContent;
                //pageStack.pop();
            }
        }
    }

    Component {
        id: openFileDialog
        OpenDialog {
            onOpenFile: {
                // TODO: Load videoPlayer function
                mainWindow.firstPage.originalUrl = path
                mainWindow.firstPage.streamUrl = path
            }
        }
    }

    Drawer {
        id: drawer

        width: parent.width
        height: parent.height
        anchors.bottom: parent.bottom
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
                    urlField.text = hurl
                    drawer.open = !drawer.open
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

            TextField {
                id: urlField
                placeholderText: "Type in URL here"
                anchors.centerIn: parent
                width: Screen.width - 20
                focus: true
                Component.onCompleted: {
                    // console.debug("StreamUrl :" + streamUrl) // DEBUG
                    if (streamUrl !== "") {
                        text = streamUrl;
                        selectAll();
                    }
                }
            }

            Button {
                id: historyBtn
                anchors.left: urlField.left
                anchors.top: urlField.bottom
                text: "History"
                onClicked: {
                    //DB.getHistory();
                    drawer.open = !drawer.open
                }
            }

            Button {
                id: openFileBtn
                anchors.top: urlField.bottom
                anchors.right: urlField.right
                text: "Browse Files"
                visible: true
                onClicked: {
                    if (mainWindow.firstPage.openDialogType === "adv") pageStack.push(Qt.resolvedUrl("fileman/Main.qml"), {dataContainer: mainWindow.firstPage});
                    else if (mainWindow.firstPage.openDialogType === "gallery") pageStack.push(mainWindow.firstPage.videoPickerComponent);
                    else if (mainWindow.firstPage.openDialogType === "simple") pageStack.push(mainWindow.firstPage.openDialog);
                }
            }

            Button {
                id: addToBookmarkBtn
                anchors.top: historyBtn.bottom
                anchors.topMargin: 15
                //anchors.right: historyBtn.right
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Add to bookmarks"
                visible: {
                    if (urlField.text !== "") return true
                    else return false
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AddBookmark.qml"), { bookmarks: mainWindow.modelBookmarks, editBookmark: false, bookmarkUrl: urlField.text });
                }
            }
        }

    }


}


