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
import QtDocGallery 5.0
import Sailfish.Gallery 1.0
import Nemo.Configuration 1.0
import "helper"
import "fileman"
import "helper/otherComponents"

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations


    signal updateCover
    signal removeFile(string url)

    property bool _isLandscape: (page.orientation === Orientation.Landscape || page.orientation === Orientation.LandscapeInverted)

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
    property string onlyMusicState: "default"
    property bool isLiveStream: false
    property bool alwaysYtdl: false
    property bool isDash: false
    property bool showMinPlayer: false
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
    property string ytQualWanted: "720p"
    property string ytdlQual: {
        if (ytQualWanted == "720p") return "best"
        else if (ytQualWanted == "480p") return "135"
        else if (ytQualWanted == "360p") return "18"
        else if (ytQualWanted == "240p") return "36"
    }

    ////////////////////////////////////////////////////

    // Aliase
    property alias videoPickerComponent: videoPickerComponent
    property alias openFileComponent: openFileComponent
    property alias historyModel: historyModel
    property alias searchHistoryModel: searchHistoryModel

    property variant busy: mainWindow.busy
    property variant errTxt: mainWindow.errTxt

    Component.onCompleted: {
        // Initialize the database
        DB.initialize();
        DB.getHistory();
        DB.getSearchHistory();
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

    function addSearchHistory(searchTerm) {
        //console.debug("Called addSearchHistory with searchTerm : " + searchTerm)
        if (searchHistoryModel.containsTerm(searchTerm)) {
            return;
        } else searchHistoryModel.append({"searchTerm": searchTerm});
    }

    function bbusy() {
        busy.visible = true
        busy.running = true
    }

    function updateYtdl() {
        bbusy();
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

    ListModel {
        id: searchHistoryModel

        function containsTerm(term) {
            for (var i=0; i<count; i++) {
                if (get(i).searchTerm == term)  {
                    return true;
                }
            }
            return false;
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
                mainWindow.firstPage.originalUrl = selectedContent;
                mainWindow.firstPage.streamUrl = selectedContent;
                mainWindow.firstPage.autoplay = true;
                mainWindow.firstPage.isPlaylist = false;
                mainWindow.firstPage.isLiveStream = false;
                mainWindow.firstPage.loadPlayer();
            }
        }
    }

    Component {
        id: openFileComponent
        OpenDialog {
            path: _fm.getHome() + "/Videos"
            filter: ["*"]
            onFileOpen: {
                // Clear Playlist and add to playlist maybe
                //mainWindow.modelPlaylist.clear();
                //mainWindow.modelPlaylist.addTrack(path,"");
                mainWindow.firstPage.originalUrl = path;
                mainWindow.firstPage.streamUrl = path;
                mainWindow.firstPage.autoplay = true;
                mainWindow.firstPage.isPlaylist = false;
                mainWindow.firstPage.isLiveStream = false;
                mainWindow.firstPage.loadPlayer();
            }
        }
    }

    ConfigurationGroup {
        id: settings
        path: "/apps/llsvplayer"

        property real scale: 2
    }

//    DocumentGalleryModel {
//        id: videosModel

//        rootType: DocumentGallery.Video
//        autoUpdate: true
//        properties: ["url", "title", "lastModified", "duration"]
//        sortProperties: ["-lastModified"]
//        filter: GalleryStartsWithFilter { property: "title"; value: searchField.text.toLowerCase().trim() }
//    }

    VideoModel {
        id: videosModel
    }

    Formatter {
        id: formatter
    }

    SilicaFlickable {
        id: videoFlick
        anchors.fill: parent

        MultiPointTouchArea {
            id: multiPointTouchArea
            anchors.fill: parent
            minimumTouchPoints: 1
            maximumTouchPoints: 2
            onTouchUpdated: (touchPoints.length === 2) ? pulley.enabled = false : pulley.enabled = true

            PinchArea {
                id: pinchArea
                MouseArea{ anchors.fill: parent; propagateComposedEvents: true }
                enabled: true
                pinch.target: scale
                pinch.maximumScale: 2
                pinch.minimumScale: 0
                anchors.fill: parent
            }
        }


        Item {
            id: scale
            scale: settings.scale
            onScaleChanged: {
                if  (Math.round(scale.scale) !== settings.scale)
                    settings.scale = scale.scale
            }
        }

        PageHeader {
            id: pageHeader
            title: "LLs Video Player"
        }

        SearchField {
            id: searchField
            anchors.top: pageHeader.bottom
            width: parent.width
        }

        PullDownMenu {
            id: pulley
            MenuItem {
                text: qsTr("About ")+ appname
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
            }
            MenuItem {
                text: qsTr("History")
                onClicked: pageStack.push(Qt.resolvedUrl("HistoryPage.qml"), {dataContainer: page, modelHistory: historyModel});
            }
            MenuItem {
                text: qsTr("Bookmarks")
                onClicked: pageStack.push(Qt.resolvedUrl("BookmarksPage.qml"), {dataContainer: page, modelBookmarks: mainWindow.modelBookmarks});
            }
            MenuItem {
                text: qsTr("Enter URL")
                onClicked: pageStack.push(Qt.resolvedUrl("OpenURLPage.qml"), {dataContainer: page});
            }

            MenuItem {
                text: qsTr("Show Player")
                onClicked: {
                    minPlayerLoader.active = true;
                    minPlayerLoader.sourceComponent = minPlayerComponent
                    minPlayerLoader.item.show()
                }
                visible: minPlayer.source != ""
            }
        }


        SilicaGridView {
            id: gridView
            model: videosModel.model
            enabled: !pinchArea.pinch.active

            anchors.top: searchField.bottom
            width: parent.width
            height: parent.height - pageHeader.height - searchField.height

            cellWidth: _isLandscape ? Screen.height / Math.round(Screen.height / (Screen.width/(4-Math.floor(scale.scale)))) :  Screen.width/(4-Math.floor(scale.scale))
            cellHeight: cellWidth
            clip: true

            Behavior on cellWidth {
                PropertyAnimation {
                    id: resizeAnimation
                    easing.type: Easing.InOutQuad;
                    easing.amplitude: 2.0;
                    easing.period: 1.5
                }
            }

            ViewPlaceholder {
                text: qsTr("No videos")
                enabled: videosModel.count === 0
            }

            delegate: ThumbnailVideo {
                id: thumbnail
                title: model.title
                source: resizeAnimation.running ? "" : model.url
                size: gridView.cellWidth
                opacity: 1
                mimeType: model.mimeType
                duration: model.duration > 3600 ? formatter.formatDuration(model.duration, Formatter.DurationLong) :
                                                  formatter.formatDuration(model.duration, Formatter.DurationShort)
                onClicked: {
                    var fileUrl = videosModel.get(index).url
                    originalUrl = fileUrl;
                    streamUrl = fileUrl;
                    autoplay = true;
                    isPlaylist = false;
                    isLiveStream = false;
                    loadPlayer();
                }


                Rectangle {
                    anchors.fill: parent

                    color: parent.down ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity) : "transparent"
                }
            }
        }




        ListModel {
            id: menuButtons

            ListElement {
                btnId: "youtubeBtn"
                name: qsTr("Search on Youtube")
                colour: "red"
                bicon: "images/icon-l-service-youtube.png"
            }
            ListElement {
                btnId: "openFileBtn"
                name: qsTr("Browse Files")
                colour: "blue"
                bicon: "images/icon-l-media-files.png"
            }
        }

        Component {
            id: menuButtonsDelegate
            ItemButton {
                id: historyBtn
                width: actionBar.width
                height: Theme.itemSizeMedium
                text: qsTr(name)
                onClicked: {
                    errTxt.visible = false;
                    autoplay = false;
                    if (btnId == "historyBtn") drawer.open = !drawer.open
                    else if (btnId == "bookmarksBtn")
                        pageStack.push(Qt.resolvedUrl("BookmarksPage.qml"), {dataContainer: page, modelBookmarks: mainWindow.modelBookmarks});
                    else if (btnId == "youtubeBtn")
                        pageStack.push(Qt.resolvedUrl("YTSearchResultsPage.qml"), {dataContainer: page});
                    else if (btnId == "openFileBtn") {
                        if (mainWindow.firstPage.openDialogType === "adv" || mainWindow.firstPage.openDialogType === "simple")
                            pageStack.push(mainWindow.firstPage.openFileComponent);
                        else if (mainWindow.firstPage.openDialogType === "gallery") pageStack.push(mainWindow.firstPage.videoPickerComponent);
                    }
                    else if (btnId == "openUrlBtn") {
                        pageStack.push(Qt.resolvedUrl("OpenURLPage.qml"), {dataContainer: page});
                    }
                    else if (btnId == "playlistBtn") {
                        openPlaylist();
                    }
                }
                onPressAndHold: {
                    if (btnId == "youtubeBtn")
                        pageStack.push(Qt.resolvedUrl("SecondPage.qml"), {dataContainer: page});
                }

                color: colour
                icon: Qt.resolvedUrl(bicon)
            }
        }

        DockedPanel {
            id: actionBar
            width: parent.width
            height: Theme.itemSizeMedium * 2

            dock: Dock.Bottom
            open: true

            Rectangle {
                anchors.fill: parent
                color: Theme.overlayBackgroundColor
                opacity: 0.8
            }

            SilicaListView {
                id: actionList
                width: parent.width
                height: childrenRect.height

                clip: true

                property TextField urlField
                property PageHeader pageHeader

                //model: menuButtons
                delegate: menuButtonsDelegate
                snapMode: ListView.SnapToItem
                populate: Transition {
                    NumberAnimation { properties: "x,y"; duration: 400 }
                }
                Component.onCompleted: {
                    actionList.model = menuButtons
                }
            } // SilicaactionListView
        }
    }

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
            isYtSearchRunning = false
            if (!isYtSearchAborted) {
                if (message != "") {
                    errTxt.visible = true
                    errTxt.text = message
                }
            }
            else {
                isYtSearchAborted = false
            }
        }
        onUpdateComplete: {
            busy.running = false
            busy.visible = false
            errTxt.visible = true
            errTxt.text = qsTr("Youtube-Dl updated.")
        }
    }

} // Page


