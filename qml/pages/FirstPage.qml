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
    allowedOrientations: defaultAllowedOrientations


    signal updateCover
    signal removeFile(string url)

    // Settings /////////////////////////////////////////
    property string openDialogType: "adv"
    property bool enableSubtitles: true
    property variant subtitlesSize: Theme.fontSizeMedium
    property bool boldSubtitles: false
    property string subtitlesColor: Theme.highlightColor
    property bool liveView: true
    property bool ytdlStream: false
    property bool subtitleSolid: false
    property bool isPlaylist: false
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
    property alias historyModel: historyModel

    property variant busy: mainWindow.busy

    Component.onCompleted: {
        // Initialize the database
        DB.initialize();
        DB.getHistory();
    }

    onStreamTitleChanged: {
        //console.debug("[firstPage.qml] streamTitle: " + streamTitle)
    }

    onStreamUrlChanged: {
        if (! ytdlStream) streamTitle = ""  // Reset Stream Title here
        ytQual = ""
    }

    onSubtitlesSizeChanged: {
        if (subtitlesSize != Theme.fontSizeSmall && subtitlesSize != Theme.fontSizeMedium && subtitlesSize != Theme.fontSizeLarge && subtitlesSize != Theme.fontSizeExtraLarge) {
            if (subtitlesSize == "small") mainWindow.firstPage.subtitlesSize = Theme.fontSizeSmall
            else if (subtitlesSize == "medium") mainWindow.firstPage.subtitlesSize = Theme.fontSizeMedium
            else if (subtitlesSize == "large") mainWindow.firstPage.subtitlesSize = Theme.fontSizeLarge
            else if (subtitlesSize == "extralarge") mainWindow.firstPage.subtitlesSize = Theme.fontSizeExtraLarge
            else mainWindow.firstPage.subtitlesSize = Theme.fontSizeMedium
        }
    }

    function loadPlayer() {
        pageStack.push(Qt.resolvedUrl("videoPlayer.qml"), {dataContainer: page});
    }

    function addHistory(url,title) {
        //console.debug("Adding " + url);
        historyModel.append({"hurl": url, "htitle": title});
    }

    function add2History(url,title) {
        if (historyModel.containsTitle(title) || historyModel.containsUrl(url)) {
            historyModel.removeUrl(url);
        }
        historyModel.append({"hurl": url, "htitle": title});
    }

    function updateYtdl() {
        busy.visible = true
        busy.running = true
        _ytdl.updateYtdl();
    }

    function openPlaylist() {
        pageStack.push(Qt.resolvedUrl("PlaylistPage.qml"), {dataContainer: page, modelPlaylist: mainWindow.modelPlaylist});
    }

    ListModel {
        id: historyModel

        function containsTitle(htitle) {
            for (var i=0; i<count; i++) {
                if (get(i).htitle == htitle)  {
                    return true;
                }
            }
            return false;
        }
        function containsUrl(hurl) {
            for (var i=0; i<count; i++) {
                if (get(i).hurl == hurl)  {
                    return true;
                }
            }
            return false;
        }
        function removeUrl(hurl) {
            for (var i=0; i<count; i++) {
                if (get(i).hurl == hurl)  {
                    remove(i)
                }
            }
            return;
        }
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
            path: "/home/nemo/Videos"
            filter: ["*.*"]
            onFileOpen: {
                mainWindow.firstPage.originalUrl = path;
                mainWindow.firstPage.streamUrl = path;
                mainWindow.firstPage.loadPlayer();
            }
        }
    }



    ListModel {
        id: menuButtons

        ListElement {
            btnId: "historyBtn"
            name: "History"
            colour: "gray"
            bicon: "images/icon-l-backup.png"
        }
        ListElement {
            btnId: "bookmarksBtn"
            name: "Bookmarks"
            colour: "brown"
            bicon: "images/icon-l-star.png"
        }
        ListElement {
            btnId: "youtubeBtn"
            name: "Search on Youtube"
            colour: "red"
            bicon: "images/icon-l-service-youtube.png"
        }
        ListElement {
            btnId: "openFileBtn"
            name: "Browse Files"
            colour: "blue"
            bicon: "images/icon-l-media-files.png"
        }
        ListElement {
            btnId: "openUrlBtn"
            name: "Enter URL"
            colour: "green"
            bicon: "images/icon-l-redirect.png"
        }
        ListElement {
            btnId: "playlistBtn"
            name: "Playlists"
            colour: "yellow"
            bicon: "images/icon-l-clipboard.png"
        }
    }

    Component {
        id: menuButtonsDelegate
        ItemButton {
            id: historyBtn
            width: grid.cellWidth
            height: grid.cellHeight
            text: qsTr(name)
            onClicked: {
                errTxt.visible = false;
                if (btnId == "historyBtn") drawer.open = !drawer.open
                else if (btnId == "bookmarksBtn")
                    pageStack.push(Qt.resolvedUrl("BookmarksPage.qml"), {dataContainer: page, modelBookmarks: mainWindow.modelBookmarks});
                else if (btnId == "youtubeBtn")
                    pageStack.push(Qt.resolvedUrl("SecondPage.qml"), {dataContainer: page});
                else if (btnId == "openFileBtn") {
                    if (mainWindow.firstPage.openDialogType === "adv") pageStack.push(Qt.resolvedUrl("fileman/Main.qml"), {dataContainer: mainWindow.firstPage});
                    else if (mainWindow.firstPage.openDialogType === "gallery") pageStack.push(mainWindow.firstPage.videoPickerComponent);
                    else if (mainWindow.firstPage.openDialogType === "simple") pageStack.push(mainWindow.firstPage.openFileComponent);
                }
                else if (btnId == "openUrlBtn") {
                   pageStack.push(Qt.resolvedUrl("OpenURLPage.qml"), {dataContainer: page});
                }
                else if (btnId == "playlistBtn") {
                   openPlaylist();
                }
            }
            color: colour
            icon: Qt.resolvedUrl(bicon)
        }
    }

    Drawer {
        id: drawer

        anchors.fill: parent

        dock: page.isPortrait ? Dock.Top : Dock.Left

        background: SilicaListView {
            anchors.fill: parent
            model: historyModel

            VerticalScrollDecorator {}

            delegate: ListItem {
                id: listItem

                Label {
                    x: Theme.paddingLarge
                    text: htitle
                    anchors.verticalCenter: parent.verticalCenter
                    color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    streamUrl = hurl
                    loadPlayer();
                }
            }
        }

        SilicaGridView {
            id: grid
            width: parent.width
            height: page.height

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

            MouseArea {
                enabled: drawer.open
                anchors.fill: grid
                onClicked: drawer.open = false
            }

            property TextField urlField
            property PageHeader pageHeader

            header: PageHeader {
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
                        grid.urlField = urlField
                        // console.debug("StreamUrl :" + streamUrl) // DEBUG
                        if (streamUrl !== "") {
                            text = streamUrl;
                            selectAll();
                        }
                    }
                }
                Component.onCompleted: grid.pageHeader = pageHeader
            }
            cellWidth: {
                if (page.orientation == Orientation.PortraitInverted || page.orientation == Orientation.Portrait)
                    page.width / 2
                else
                    page.width / 4
            }
            cellHeight: {
                if (page.orientation == Orientation.PortraitInverted || page.orientation == Orientation.Portrait)
                    (page.height / 3) - pageHeader.height / 2
                else
                    (page.height / 2) - pageHeader.height / 2
            }
            //model: menuButtons
            delegate: menuButtonsDelegate
            snapMode: GridView.SnapToRow
            populate: Transition {
                NumberAnimation { properties: "x,y"; duration: 400 }
            }
            Component.onCompleted: {
                grid.model = menuButtons
            }
        } // SilicaGridView
    } // Drawer

    Connections {
        target: _ytdl
        onStreamUrlChanged: {
            if (changedUrl != "") {  // Don't load empty stuff
                page.streamUrl = changedUrl;
                page.originalUrl = _ytdl.getReqUrl();
                busy.running = false
                busy.visible = false
                page.ytdlStream = true
                page.loadPlayer();
            }
            else {
                // Fail silently
                busy.running = false
                busy.visible = false
            }
        }
        onSTitleChanged: {
            if (sTitle != "") {
                page.streamTitle = sTitle
            }
        }
        onError: {
            busy.running = false
            if (message != "") {
                errTxt.visible = true
                errTxt.text = message
            }
        }
        onUpdateComplete: {
            busy.running = false
            busy.visible = false
            errTxt.visible = true
            errTxt.text = qsTr("Youtube-Dl updated.")
        }
    }

    Rectangle {
        color: "black"
        opacity: 0.60
        anchors.fill: parent
        visible: {
            if (busy.running) return true;
            else if (errTxt.visible) return true;
            else return false;
        }
    }

    TextArea {
        id: errTxt
        anchors.top: parent.top
        height: parent.height - (dismissBtn.height + Theme.paddingLarge)
        width: parent.width
        font.pointSize: Theme.fontSizeSmall
        color: Theme.primaryColor
        visible: false
        background: null
        wrapMode: TextEdit.WordWrap
        readOnly: true
    }
    Button {
        id: dismissBtn
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        visible: errTxt.visible
        text: qsTr("Dismiss")
        onClicked: {
            if (errTxt.visible) errTxt.visible = false;
        }
    }

} // Page


