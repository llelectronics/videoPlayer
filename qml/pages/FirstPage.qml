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
import Sailfish.Media 1.0
import Sailfish.Pickers 1.0
//import Sailfish.Gallery 1.0
import "helper"
import "fileman"

Page {
    id: page
    allowedOrientations: Orientation.All
    property string videoDuration: {
        if (videoPoster.duration > 3599) return Format.formatDuration(videoPoster.duration, Formatter.DurationLong)
        else return Format.formatDuration(videoPoster.duration, Formatter.DurationShort)
    }
    property string videoPosition: {
        if (videoPoster.position > 3599) return Format.formatDuration(videoPoster.position, Formatter.DurationLong)
        else return Format.formatDuration(videoPoster.position, Formatter.DurationShort)
    }
    property string originalUrl
    property string streamUrl
    property bool youtubeDirect: true
    property bool isYtUrl: false
    property string streamTitle
    property string title: videoPoster.player.metaData.title ? videoPoster.player.metaData.title : ""
    property string artist: videoPoster.player.metaData.albumArtist ? videoPoster.player.metaData.albumArtist : ""
    property int subtitlesSize: 25
    property bool boldSubtitles: false
    property string subtitlesColor: Theme.highlightColor
    property bool enableSubtitles: true
    property alias onlyMusic: onlyMusic
    property alias videoPoster: videoPoster
    property variant currentVideoSub: []
    signal updateCover
    signal removeFile(string url)
    property alias videoPickerComponent: videoPickerComponent
    property alias openDialog: openFileDialog
    property alias showTimeAndTitle: showTimeAndTitle
    property alias pulley: pulley
    property string openDialogType: "adv"
    property string url720p
    property string url480p
    property string url360p
    property string url240p
    property string ytQual
    property bool liveView: true

    property Page dPage

    function findBaseName(url) {
        var fileName = url.substring(url.lastIndexOf('/') + 1);
        var dot = fileName.lastIndexOf('.');
        return dot == -1 ? fileName : fileName.substring(0, dot);
    }

    Component.onCompleted: {
        // Initialize the database
        DB.initialize();
        //            DB.showHistoryLast();
        //            DB.getHistory();
    }

    onStreamUrlChanged: {
        //Write into history database
        DB.addHistory(streamUrl);
        if (errorDetail.visible && errorTxt.visible) { errorDetail.visible = false; errorTxt.visible = false }
        streamTitle = ""  // Reset Stream Title here
        ytQual = ""
        if (YT.checkYoutube(streamUrl)=== true) {
            //console.debug("[firstPage.qml] Youtube Link detected loading Streaming URLs")
            // Reset Stream urls
            url240p = ""
            url360p = ""
            url480p = ""
            url720p = ""
            YT.getYoutubeTitle(streamUrl);
            var ytID = YT.getYtID(streamUrl);
            YT.getYoutubeStream(ytID);
        }
        else if (YT.checkYoutube(originalUrl) === true) {
            console.debug("[firstPage.qml] Loading Youtube Title from original URL")
            YT.getYoutubeTitle(originalUrl);
        }
        if (streamTitle == "") dPage.title = findBaseName(streamUrl)
    }

    onStreamTitleChanged: {
        if (streamTitle != "") dPage.title = streamTitle
    }

    Rectangle {
        id: headerBg
        width:urlHeader.width
        height: urlHeader.height
        visible: {
            if (urlHeader.visible || titleHeader.visible) return true
            else return false
        }
        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: "transparent" } //Theme.highlightColor} // Black seems to look and work better
        }
    }

    PageHeader {
        id: urlHeader
        title: findBaseName(streamUrl)
        visible: {
            if (titleHeader.visible == false && pulley.visible && mainWindow.applicationActive) return true
            else return false
        }
        _titleItem.font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeLarge : Theme.fontSizeHuge
        states: [
            State {
                name: "cover"
                PropertyChanges {
                    target: urlHeader
                    visible: true
                }
            }
        ]
    }
    PageHeader {
        id: titleHeader
        title: streamTitle
        visible: {
            if (streamTitle != "" && pulley.visible && mainWindow.applicationActive) return true
            else return false
        }
        _titleItem.font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeLarge : Theme.fontSizeHuge
        states: [
            State {
                name: "cover"
                PropertyChanges {
                    target: titleHeader
                    visible: true
                }
            }
        ]
    }

    function videoPauseTrigger() {
        // this seems not to work somehow
        if (videoPoster.player.playbackState == MediaPlayer.PlayingState) videoPoster.player.pause();
        else if (videoPoster.source.toString().length !== 0) videoPoster.player.play();
        if (videoPoster.controls.opacity === 0.0) videoPoster.toggleControls();

    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
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
            MenuItem {
                text: "Bookmarks"
                onClicked: pageStack.push(Qt.resolvedUrl("BookmarksPage.qml"), {dataContainer: page, modelBookmarks: mainWindow.modelBookmarks});
            }
            MenuItem {
                text: "Search Youtube"
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"), {dataContainer: page});
            }
            MenuItem {
                text: "Open"
                onClicked: pageStack.push(Qt.resolvedUrl("OpenURLPage.qml"), {dataContainer: page, streamUrl: streamUrl});
            }
        }

        Image {
            id: onlyMusic
            anchors.centerIn: parent
            source: Qt.resolvedUrl("images/audio.png")
            opacity: 0.0
            Behavior on opacity { FadeAnimation { } }
        }

        ProgressCircle {
            id: progressCircle

            anchors.centerIn: parent
            visible: false

            Timer {
                interval: 32
                repeat: true
                onTriggered: progressCircle.value = (progressCircle.value + 0.005) % 1.0
                running: visible
            }
        }

        Label {
            id: subtitlesText

            z: 100
            anchors { fill: parent; margins: page.inPortrait ? 10 : 50 }
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            font.pixelSize: subtitlesSize
            font.bold: boldSubtitles
            color: subtitlesColor
            visible: (enableSubtitles) && (currentVideoSub) ? true : false
            onTextChanged: {
                //console.debug("[firstPage] Subtitletext: " + text)
            }
        }

        function getSubtitles() {
            subsGetter.sendMessage(streamUrl);
        }

        function setSubtitles(subtitles) {
            currentVideoSub = subtitles;
            //console.debug("[firstPage] subtitles: " + currentVideoSub)
        }

        WorkerScript {
            id: subsGetter

            source: "helper/getsubtitles.js"
            onMessage: {
                flick.setSubtitles(messageObject);
                //console.debug("[firstPage] subtitleMessageObject: " + messageObject);
            }
        }

        function checkSubtitles() {
            subsChecker.sendMessage({"position": videoPoster.position, "subtitles": currentVideoSub})
            //console.debug("[firstPage] checkSubtitles activated with: " + currentVideoSub)
        }

        WorkerScript {
            id: subsChecker

            source: "helper/checksubtitles.js"
            onMessage: {
                subtitlesText.text = messageObject
                //console.debug("[firstPage] subsChecker MessageObject: " + messageObject);
            }
        }

        Column {
            id: errorBox
            anchors.top: parent.top
            anchors.topMargin: 65
            spacing: 15
            width: parent.width
            height: parent.height
            visible: {
                if (errorTxt.text !== "" || errorDetail.text !== "" ) return true;
                else return false;
            }
            Label {
                // TODO: seems only show error number. Maybe disable in the future
                id: errorTxt
                text: ""

                //            anchors.top: parent.top
                //            anchors.topMargin: 65
                font.bold: true
            }


            TextArea {
                id: errorDetail
                text: ""
                //                visible: {
                //                    if (text !== "" && page.orientation === Orientation.Portrait ) return true;
                //                    else return false;
                //                }
                width: parent.width
                height: parent.height / 3
                anchors.horizontalCenter: parent.horizontalCenter
                //            anchors.top: errorTxt.bottom
                //            anchors.topMargin: 15
                font.bold: false
                color: "white"//                visible: {
                //                    if (text !== "" && page.orientation === Orientation.Portrait ) return true;
                //                    else return false;
                //                }
            }
        }
        MouseArea {
            id: errorClick
            anchors.fill: errorBox
            enabled: {
                if (errorTxt.text != "") return true
                else return false
            }
            onClicked: {
                errorTxt.text = ""
                errorDetail.text = ""
                errorBox.visible = false
            }
            z:99  // above all to hide error message
        }

        Item {
            id: mediaItem
            property bool active : true
            visible: active && mainWindow.applicationActive
            anchors.fill: parent

            VideoPoster {
                id: videoPoster
                width: page.orientation === Orientation.Portrait ? Screen.width : Screen.height
                height: page.height

                player: mediaPlayer

                //duration: videoDuration
                active: mediaItem.active
                source: streamUrl
                onSourceChanged: {
                    //play();  // autoPlay TODO: add config for it
                    position = 0;
                    player.seek(0);
                    player.stop();
                }
                //source: "file:///home/nemo/Videos/eva.mp4"
                //source: "http://netrunnerlinux.com/vids/default-panel-script.mkv"
                //source: "http://www.ytapi.com/?vid=lfAixpkzcBQ&format=direct"

                onPlayClicked: {
                    toggleControls();
                    if (enableSubtitles) {
                        flick.getSubtitles();
                    }
                }

                function toggleControls() {
                    //console.debug("Controls Opacity:" + controls.opacity);
                    if (controls.opacity === 0.0) {
                        //console.debug("Show controls");
                        controls.opacity = 1.0;
                    }
                    else {
                        //console.debug("Hide controls");
                        controls.opacity = 0.0;
                    }
                    page.showNavigationIndicator = !page.showNavigationIndicator
                    pulley.visible = !pulley.visible
                }

                function hideControls() {
                    controls.opacity = 0.0
                    pulley.visible = false
                    page.showNavigationIndicator = false
                }

                function showControls() {
                    controls.opacity = 1.0;
                    pulley.visible = false
                    page.showNavigationIndicator = true
                }


                onClicked: {
                    if (drawer.open) drawer.open = false
                    else {
                        if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                            //console.debug("Mouse values:" + mouse.x + " x " + mouse.y)
                            var middleX = width / 2
                            var middleY = height / 2
                            //console.debug("MiddleX:" + middleX + " MiddleY:"+middleY + " mouse.x:"+mouse.x + " mouse.y:"+mouse.y)
                            if ((mouse.x >= middleX - 64 && mouse.x <= middleX + 64) && (mouse.y >= middleY - 64 && mouse.y <= middleY + 64)) {
                                mediaPlayer.pause();
                                if (controls.opacity === 0.0) toggleControls();
                                progressCircle.visible = false;
                                if (! mediaPlayer.seekable) mediaPlayer.stop();
                            }
                            else {
                                toggleControls();
                            }
                        } else {
                            //mediaPlayer.play()
                            //console.debug("clicked something else")
                            toggleControls();
                        }
                    }
                }
                onPressAndHold: {
                    //console.debug("[Press and Hold detected]")
                    if (! drawer.open) drawer.open = true
                }
                onPositionChanged: {
                    if ((enableSubtitles) && (currentVideoSub)) flick.checkSubtitles()
                }
            }
        }
    }
    Drawer {
        id: drawer
        width: parent.width
        height: parent.height
        anchors.bottom: parent.bottom
        dock: Dock.Bottom
        foreground: flick
        backgroundSize: {
            if (page.orientation === Orientation.Portrait) return parent.height / 8
            else return parent.height / 6
        }
        background: Rectangle {
            anchors.fill: parent
            anchors.bottom: parent.bottom
            color: Theme.secondaryHighlightColor
            Button {
                id: ytDownloadBtn
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                text: "Download video"
                visible: {
                    if ((/^http:\/\/ytapi.com/).test(streamUrl)) return true
                    else if (isYtUrl) return true
                    else return false
                }
                //onClicked: pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": streamUrl, "downloadName": streamTitle});
                // Alternatively use direct youtube url instead of ytapi for downloads (ytapi links not always download with download manager)
                onClicked: {
                    // Filter out all chars that might stop the download manager from downloading the file
                    // Illegal chars: `~!@#$%^&*()-=+\|/?.>,<;:'"[{]}
                    streamTitle = YT.getDownloadableTitleString(streamTitle)
                    pageStack.push(Qt.resolvedUrl("ytQualityChooser.qml"), {"streamTitle": streamTitle, "url720p": url720p, "url480p": url480p, "url360p": url360p, "url240p": url240p, "ytDownload": true});
                    drawer.open = !drawer.open
                }
            }
            Button {
                id: add2BookmarksBtn
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                text : "Add to bookmarks"
                visible: {
                    if (streamTitle != "" || streamUrl != "") return true
                    else return false
                }
                onClicked: {
                    if (streamTitle != "" && !youtubeDirect) mainWindow.modelBookmarks.addBookmark(streamUrl,streamTitle)
                    else if (streamTitle != "" && youtubeDirect) mainWindow.modelBookmarks.addBookmark(originalUrl,streamTitle)
                    else if (!youtubeDirect) mainWindow.modelBookmarks.addBookmark(streamUrl,findBaseName(streamUrl))
                    else mainWindow.modelBookmarks.addBookmark(originalUrl,findBaseName(originalUrl))
                    drawer.open = !drawer.open
                }
            }
        }

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
                //pageStack.pop();
            }
        }
    }

    Component {
        id: openFileDialog
        OpenDialog {
            onOpenFile: {
                mainWindow.firstPage.originalUrl = path
                mainWindow.firstPage.streamUrl = path
            }
        }
    }

    children: [

        // Always use a black background
        Rectangle {
            anchors.fill: parent
            color: "black"
            visible: video.visible
        },

        VideoOutput {
            id: video
            anchors.fill: parent

            source: MediaPlayer {
                id: mediaPlayer
                function loadMetaDataPage() {
                    //console.debug("Loading metadata page")
                    var mDataTitle;
                    //console.debug(metaData.title)
                    if (streamTitle != "") mDataTitle = streamTitle
                    else mDataTitle = findBaseName(streamUrl)
                    //console.debug("[mDataTitle]: " + mDataTitle)
                    dPage = pageStack.pushAttached(Qt.resolvedUrl("FileDetails.qml"), {
                                               filename: streamUrl,
                                               title: mDataTitle,
                                               artist: metaData.albumArtist,
                                               videocodec: metaData.videoCodec,
                                               resolution: metaData.resolution,
                                               videobitrate: metaData.videoBitRate,
                                               framerate: metaData.videoFrameRate,
                                               audiocodec: metaData.audioCodec,
                                               audiobitrate: metaData.audioBitRate,
                                               samplerate: metaData.sampleRate,
                                               copyright: metaData.copyright,
                                               date: metaData.date,
                                               size: metaData.size
                                           });
                }

                onDurationChanged: {
                    //console.debug("Duration(msec): " + duration);
                    videoPoster.duration = (duration/1000);
                    loadMetaDataPage();
                    if (hasAudio === true && hasVideo === false) onlyMusic.opacity = 1.0
                    else onlyMusic.opacity = 0.0;
                }
                onStatusChanged: {
                    //errorTxt.visible = false     // DEBUG: Always show errors for now
                    //errorDetail.visible = false
                    //console.debug("PlaybackStatus: " + playbackState)
                    if (mediaPlayer.status === MediaPlayer.Loading || mediaPlayer.status === MediaPlayer.Buffering || mediaPlayer.status === MediaPlayer.Stalled) progressCircle.visible = true;
                    else if (mediaPlayer.status === MediaPlayer.EndOfMedia) videoPoster.showControls();
                    else progressCircle.visible = false;
                    if (metaData.title) dPage.title = metaData.title
                }
                onError: {
                    errorTxt.text = error;
                    errorDetail.text = errorString;
                    errorBox.visible = true;
                }
            }

            visible: mediaPlayer.status >= MediaPlayer.Loaded && mediaPlayer.status <= MediaPlayer.EndOfMedia
            width: parent.width
            height: parent.height
            anchors.centerIn: page

            ScreenBlank {
                suspend: mediaPlayer.playbackState == MediaPlayer.PlayingState
            }
        }
    ]

    // Need some more time to figure that out completely
    Timer {
        id: showTimeAndTitle
        property int count: 0
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            ++count
            if (count >= 5) {
                stop()
                coverTime.fadeOut.start()
                urlHeader.state = ""
                titleHeader.state = ""
                count = 0
            } else {
                coverTime.visible = true
                if (firstPage.title.toString().length !== 0 && !mainWindow.applicationActive) titleHeader.state = "cover";
                else if (firstPage.streamUrl.toString().length !== 0 && !mainWindow.applicationActive) urlHeader.state = "cover";
            }
        }
    }

    Rectangle {
        width: parent.width
        height: Theme.fontSizeHuge
        y: coverTime.y + 10
        color: "black"
        opacity: 0.4
        visible: coverTime.visible
    }

    Item {
        id: coverTime
        property alias fadeOut: fadeout
        //visible: !mainWindow.applicationActive && liveView
        visible: false
        onVisibleChanged: {
            if (visible) fadein.start()
        }
        anchors.top: titleHeader.bottom
        anchors.topMargin: 15
        x : (parent.width / 2) - ((curPos.width/2) + (dur.width/2))
        NumberAnimation {
            id: fadein
            target: coverTime
            property: "opacity"
            easing.type: Easing.InOutQuad
            duration: 500
            from: 0
            to: 1
        }
        NumberAnimation {
            id: fadeout
            target: coverTime
            property: "opacity"
            duration: 500
            easing.type: Easing.InOutQuad
            from: 1
            to: 0
            onStopped: coverTime.visible = false;
        }
        Label {
            id: dur
            text: firstPage.videoDuration
            anchors.left: curPos.right
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeHuge
            font.bold: true
        }
        Label {
            id: curPos
            text: firstPage.videoPosition + " / "
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeHuge
            font.bold: true
        }
    }

    CoverActionList {
        id: coverAction
        enabled: liveView

//        CoverAction {
//            iconSource: "image://theme/icon-cover-next"
//        }

        CoverAction {
            iconSource: {
                if (firstPage.videoPoster.player.playbackState === MediaPlayer.PlayingState) return "image://theme/icon-cover-pause"
                else return "image://theme/icon-cover-play"
            }
            onTriggered: {
                //console.debug("Pause triggered");
                firstPage.videoPauseTrigger();
                if (!showTimeAndTitle.running) showTimeAndTitle.start();
                else showTimeAndTitle.count = 0;
                videoPoster.hideControls();
            }
        }
    }
}


