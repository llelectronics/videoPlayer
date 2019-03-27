import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import Sailfish.Media 1.0
import "helper"
import "fileman"
import org.nemomobile.mpris 1.0

Page {
    id: videoPlayerPage
    objectName: "videoPlayerPage"
    allowedOrientations: Orientation.All

    focus: true

    property QtObject dataContainer

    property string videoDuration: {
        if (videoPoster.duration > 3599) return Format.formatDuration(videoPoster.duration, Formatter.DurationLong)
        else return Format.formatDuration(videoPoster.duration, Formatter.DurationShort)
    }
    property string videoPosition: {
        if (videoPoster.position > 3599) return Format.formatDuration(videoPoster.position, Formatter.DurationLong)
        else return Format.formatDuration(videoPoster.position, Formatter.DurationShort)
    }
    property string originalUrl: dataContainer.originalUrl
    property string streamUrl: dataContainer.streamUrl
    property bool youtubeDirect: dataContainer.youtubeDirect
    property bool isYtUrl: dataContainer.isYtUrl
    property string streamTitle: dataContainer.streamTitle
    property string title: videoPoster.player.metaData.title ? videoPoster.player.metaData.title : ""
    property string artist: videoPoster.player.metaData.albumArtist ? videoPoster.player.metaData.albumArtist : ""
    property int subtitlesSize: dataContainer.subtitlesSize
    property bool boldSubtitles: dataContainer.boldSubtitles
    property string subtitlesColor: dataContainer.subtitlesColor
    property bool enableSubtitles: dataContainer.enableSubtitles
    property variant currentVideoSub: []
    property string url720p: dataContainer.url720p
    property string url480p: dataContainer.url480p
    property string url360p: dataContainer.url360p
    property string url240p: dataContainer.url240p
    property string ytQual: dataContainer.ytQual
    property string ytQualWanted: dataContainer.ytQualWanted
    property string ytdlQual: dataContainer.ytdlQual
    property bool liveView: true
    property Page dPage
    property bool autoplay: dataContainer.autoplay
    property bool savedPosition: false
    property string savePositionMsec
    property string subtitleUrl
    property bool subtitleSolid: dataContainer.subtitleSolid
    property bool isPlaylist: dataContainer.isPlaylist
    property bool isNewSource: false
    property bool isDash: dataContainer.isDash
    property string onlyMusicState: dataContainer.onlyMusicState
    property bool isLiveStream: dataContainer.isLiveStream

    property alias showTimeAndTitle: showTimeAndTitle
    property alias pulley: pulley
    property alias onlyMusic: onlyMusic
    property alias videoPoster: videoPoster


    Component.onCompleted: {
        minPlayerPanel.hide()
        if (autoplay) {
            //console.debug("[videoPlayer.qml] Autoplay activated for url: " + videoPoster.source);
            videoPoster.play();
            // TODO: Workaround somehow toggleControls() has a racing condition with something else
            pulley.visible = false;
            showNavigationIndicator = false;
            mprisPlayer.title = streamTitle;
        }
        mprisPlayer.canGoNext = mainWindow.modelPlaylist.isNext() && isPlaylist
        mprisPlayer.canGoPrevious = mainWindow.modelPlaylist.isPrev() && isPlaylist
        mprisPlayer.title = dataContainer.streamUrl
    }

    Component.onDestruction: {
        console.debug("Destruction of videoplayer")
        var sourcePath = mediaPlayer.source.toString();
        if (sourcePath.match("^file://")) {
            //console.debug("[videoPlayer.qml] Destruction going on so write : " + mediaPlayer.source + " with timecode: " + mediaPlayer.position + " to db")
            DB.addPosition(sourcePath,mediaPlayer.position);
        }
        minPlayer.seek(mediaPlayer.position)
        minPlayer.streamTitle = streamTitle
        minPlayer.isPlaylist = isPlaylist
        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) minPlayer.play();
        mediaPlayer.pause();
        minPlayerPanel.show()
//        mediaPlayer.stop();
//        mediaPlayer.source = "";
//        mediaPlayer.play();
//        mediaPlayer.stop();
//        gc();
//        video.destroy();
//        pageStack.popAttached();
    }

//    onStatusChanged: {
//        if (status == PageStatus.Deactivating) {
//            //console.debug("VidePlayer page deactivated");
//            mediaPlayer.stop();
//            video.destroy();
//        }
//    }

    onStreamUrlChanged: {
        if (errorDetail.visible && errorTxt.visible) { errorDetail.visible = false; errorTxt.visible = false }
        videoPoster.showControls();
//        dataContainer.streamTitle = ""  // Reset Stream Title here
//        dataContainer.ytQual = ""
        if (YT.checkYoutube(streamUrl)=== true) {
            //console.debug("[videoPlayer.qml] Youtube Link detected loading Streaming URLs")
            // Reset Stream urls
            dataContainer.url240p = ""
            dataContainer.url360p = ""
            dataContainer.url480p = ""
            dataContainer.url720p = ""
            YT.getYoutubeTitle(streamUrl);
            var ytID = YT.getYtID(streamUrl);
            YT.getYoutubeStream(ytID);
            dataContainer.isYtUrl = true;
        }
        else if (YT.checkYoutube(originalUrl) === true) {
            //console.debug("[videoPlayer.qml] Loading Youtube Title from original URL")
            YT.getYoutubeTitle(originalUrl);
        }
        else dataContainer.isYtUrl = false;
        if (dataContainer.streamTitle === "") dataContainer.streamTitle = mainWindow.findBaseName(streamUrl)
        dataContainer.ytdlStream = false

        if (streamUrl.toString().match("^file://") || streamUrl.toString().match("^/")) {
            savePositionMsec = DB.getPosition(streamUrl.toString());
            console.debug("[videoPlayer.qml] streamUrl= " + streamUrl + " savePositionMsec= " + savePositionMsec + " streamUrl.length = " + streamUrl.length);
            if (savePositionMsec !== "Not Found") savedPosition = true;
            else savedPosition = false;
        }
        if (isPlaylist) mainWindow.curPlaylistIndex = mainWindow.modelPlaylist.getPosition(streamUrl)
        isNewSource = true
    }

    onStreamTitleChanged: {
        if (streamTitle != "") {
            //Write into history database
            DB.addHistory(streamUrl,streamTitle);
            // Don't forgt to write it to the List aswell
            mainWindow.firstPage.add2History(streamUrl,streamTitle);
        }
    }

    Rectangle {
        id: headerBg
        width:urlHeader.width
        height: urlHeader.height + Theme.paddingMedium
        visible: {
            if (urlHeader.visible || titleHeader.visible) return true
            else return false
        }
        gradient: Gradient {
            GradientStop { position: 0.0; color: isLightTheme ? "white" : "black" }
            GradientStop { position: 1.0; color: "transparent" } //Theme.highlightColor} // Black seems to look and work better
        }
    }

    PageHeader {
        id: urlHeader
        title: mainWindow.findBaseName(streamUrl)
        _titleItem.color: isLightTheme? "black" : "white"
        visible: {
            if (titleHeader.visible == false && pulley.visible && mainWindow.applicationActive) return true
            else return false
        }
        _titleItem.font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeMedium : Theme.fontSizeHuge
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
        _titleItem.color: isLightTheme? "black" : "white"
        title: streamTitle
        visible: {
            if (streamTitle != "" && pulley.visible && mainWindow.applicationActive) return true
            else return false
        }
        _titleItem.font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeMedium : Theme.fontSizeHuge
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
        if (videoPoster.player.playbackState == MediaPlayer.PlayingState) videoPoster.pause();
        else if (videoPoster.source.toString().length !== 0) videoPoster.play();
        if (videoPoster.controls.opacity === 0.0) videoPoster.toggleControls();

    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            id: pulley
            MenuItem {
                id: ytdlMenuItem
                text: qsTr("Load with ytdl")
                visible: {
                    if ((/^http:\/\/ytapi.com/).test(mainWindow.firstPage.streamUrl)) return true
                    else if (mainWindow.firstPage.isYtUrl) return true
                    else return false
                }
                //onClicked: pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": streamUrl, "downloadName": streamTitle});
                // Alternatively use direct youtube url instead of ytapi for downloads (ytapi links not always download with download manager)
                onClicked: {
                    _ytdl.setUrl(originalUrl)
                    _ytdl.setParameter("-f " + ytdlQual)
                    _ytdl.getStreamUrl()
                    _ytdl.getStreamTitle()
                    mainWindow.firstPage.isYtUrl = false
                    mainWindow.firstPage.busy.visible = true;
                    mainWindow.firstPage.busy.running = true;
                    pageStack.pop()
                }
            }
            MenuItem {
                id: ytMenuItem
                text: qsTr("Download Youtube Video")
                visible: {
                    if ((/^http:\/\/ytapi.com/).test(mainWindow.firstPage.streamUrl)) return true
                    else if (mainWindow.firstPage.isYtUrl) return true
                    else return false
                }
                //onClicked: pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": streamUrl, "downloadName": streamTitle});
                // Alternatively use direct youtube url instead of ytapi for downloads (ytapi links not always download with download manager)
                onClicked: {
                    // Filter out all chars that might stop the download manager from downloading the file
                    // Illegal chars: `~!@#$%^&*()-=+\|/?.>,<;:'"[{]}
                    //console.debug("[FileDetails -> Download YT Video]: " + mainWindow.firstPage.youtubeDirectUrl)
                    mainWindow.firstPage.streamTitle = YT.getDownloadableTitleString(mainWindow.firstPage.streamTitle)
                    _ytdl.setUrl(originalUrl);
                    pageStack.push(Qt.resolvedUrl("ytQualityChooser.qml"), {"streamTitle": mainWindow.firstPage.streamTitle, "url720p": url720p, "url480p": url480p, "url360p": url360p, "url240p": url240p, "ytDownload": true});
                }
            }
            MenuItem {
                text: qsTr("Download")
                visible: {
                    if ((/^https?:\/\/.*$/).test(mainWindow.firstPage.streamUrl) && ytMenuItem.visible == false) return true
                    else return false
                }
                //onClicked: pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": streamUrl, "downloadName": streamTitle});
                // Alternatively use direct youtube url instead of ytapi for downloads (ytapi links not always download with download manager)
                onClicked: {
                    // Filter out all chars that might stop the download manager from downloading the file
                    // Illegal chars: `~!@#$%^&*()-=+\|/?.>,<;:'"[{]}
                    //console.debug("[FileDetails -> Download YT Video]: " + mainWindow.firstPage.youtubeDirectUrl)
                    mainWindow.firstPage.streamTitle = YT.getDownloadableTitleString(mainWindow.firstPage.streamTitle)
                    pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadName": mainWindow.firstPage.streamTitle, "downloadUrl": mainWindow.firstPage.streamUrl});
                }
            }
            MenuItem {
                text: qsTr("Add to bookmarks")
                visible: {
                    if (mainWindow.firstPage.streamTitle !== "" || mainWindow.firstPage.streamUrl !== "") return true
                    else return false
                }
                onClicked: {
                    if (isYtUrl) {
                        if (mainWindow.firstPage.streamTitle != "") mainWindow.modelBookmarks.addBookmark(mainWindow.firstPage.originalUrl,mainWindow.firstPage.streamTitle,mainWindow.firstPage.isLiveStream)
                        else mainWindow.modelBookmarks.addBookmark(mainWindow.firstPage.originalUrl,mainWindow.findBaseName(mainWindow.firstPage.originalUrl), mainWindow.firstPage.isLiveStream)
                    } else {
                        if (mainWindow.firstPage.streamTitle != "") mainWindow.modelBookmarks.addBookmark(mainWindow.firstPage.streamUrl,mainWindow.firstPage.streamTitle,mainWindow.firstPage.isLiveStream)
                        else mainWindow.modelBookmarks.addBookmark(mainWindow.firstPage.streamUrl,mainWindow.findBaseName(mainWindow.firstPage.streamUrl),mainWindow.firstPage.isLiveStream)
                    }
                }
            }
            MenuItem {
                text: qsTr("Load Subtitle")
                onClicked: pageStack.push(openSubsComponent)
            }
            MenuItem {
                text: qsTr("Play from last known position")
                visible: {
                    savedPosition
                }
                onClicked: {
                    if (mediaPlayer.playbackState != MediaPlayer.PlayingState) videoPoster.play();
                    mediaPlayer.seek(savePositionMsec)
                }
            }
        }

        AnimatedImage {
            id: onlyMusic
            anchors.centerIn: parent
            source: Qt.resolvedUrl("images/audio.png")
            opacity: 0.0
            Behavior on opacity { FadeAnimation { } }
            width: Screen.width / 1.25
            height: width
            playing: false
            state: onlyMusicState
            visible: {
                if (opacity == 0.0) false
                else true
            }

            states: [
                    State {
                        name: "default"
                        PropertyChanges {
                            target: onlyMusic;
                            source: Qt.resolvedUrl("images/audio.png")
                            width: Screen.width / 1.25
                            height: onlyMusic.width
                            rotation: 0
                            playing: false
                        }
                    },
                State {
                    name: "mc"
                    PropertyChanges {
                        target: onlyMusic;
                        source: Qt.resolvedUrl("images/audio-mc-anim.gif")
                        width: Screen.height / 1.25
                        height: Screen.width - Theme.paddingMedium
                        rotation: 90 -videoPlayerPage.rotation
                        playing: videoPoster.playing
                    }
                },
                State {
                    name: "eq"
                    PropertyChanges {
                        target: onlyMusic;
                        source: Qt.resolvedUrl("images/audio-eq-anim.gif")
                        width: Screen.height / 1.25
                        height: Screen.width / 0.8
                        rotation: 90 -videoPlayerPage.rotation
                        playing: videoPoster.playing
                    }
                }

                ]

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

        Loader {
            id: subTitleLoader
            active: enableSubtitles
            sourceComponent: subItem
            anchors.fill: parent
        }

        Component {
            id: subItem
            SubtitlesItem {
                id: subtitlesText
                anchors { fill: parent; margins: videoPlayerPage.inPortrait ? 10 : 50 }
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                pixelSize: subtitlesSize
                bold: boldSubtitles
                color: subtitlesColor
                visible: (enableSubtitles) && (currentVideoSub) ? true : false
                isSolid: subtitleSolid
            }
        }

        Component {
            id: openSubsComponent
            OpenDialog {
                onFileOpen: {
                    subtitleUrl = path
                    pageStack.pop()
                }
            }
        }

        Rectangle {
            color: isLightTheme ? "white" : "black"
            opacity: 0.60
            anchors.fill: parent
            visible: {
                if (errorBox.visible) return true;
                else return false;
            }
            z:98
            MouseArea {
                anchors.fill: parent
            }
        }

        Column {
            id: errorBox
            anchors.top: parent.top
            anchors.topMargin: 65
            spacing: 15
            width: parent.width
            height: parent.height
            z:99
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
                onTextChanged: {
                    if (text !== "") visible = true;
                }
            }


            TextArea {
                id: errorDetail
                text: ""
                width: parent.width
                height: parent.height / 2.5
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: false
                onTextChanged: {
                    if (text !== "") visible = true;
                }
                background: null
                readOnly: true
            }
        }
        Button {
            text: qsTr("Dismiss")
            onClicked: {
                errorTxt.text = ""
                errorDetail.text = ""
                errorBox.visible = false
            }
            visible: errorBox.visible
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            z: {
                if ((errorBox.z + 1) > (videoPoster.z + 1)) errorBox.z + 1
                else videoPoster.z + 1
            }
        }

        Item {
            id: mediaItem
            property bool active : true
            visible: active && mainWindow.applicationActive
            anchors.fill: parent

            VideoPoster {
                id: videoPoster
                width: videoPlayerPage.orientation === Orientation.Portrait ? Screen.width : Screen.height
                height: videoPlayerPage.height

                player: mediaPlayer

                //duration: videoDuration
                active: mediaItem.active
                source: streamUrl
                onSourceChanged: {
                    position = 0;
                    player.seek(0);
                    //console.debug("Source changed to " + source)
                }
                //source: "file:///home/nemo/Videos/eva.mp4"
                //source: "http://netrunnerlinux.com/vids/default-panel-script.mkv"
                //source: "http://www.ytapi.com/?vid=lfAixpkzcBQ&format=direct"

                function play() {
                    playClicked();
                }

                onPlayClicked: {
                    console.debug("Loading source into player")
                    player.source = source;
                    console.debug("Starting playback")
                    player.play();
                    if (isDash) minPlayer.play();
                    hideControls();
                    if (enableSubtitles) {
                        subTitleLoader.item.getSubtitles(subtitleUrl);
                    }
                    if (mediaPlayer.hasAudio === true && mediaPlayer.hasVideo === false) onlyMusic.playing = true
                }

                onNextClicked: {
                    if (isPlaylist && mainWindow.modelPlaylist.isNext()) {
                        next();
                    }
                }

                onPrevClicked: {
                    if (isPlaylist && mainWindow.modelPlaylist.isPrev()) {
                        prev();
                    }
                }

                function toggleControls() {
                    //console.debug("Controls Opacity:" + controls.opacity);
                    if (controls.opacity === 0.0) {
                        //console.debug("Show controls");
                        showControls()
                    }
                    else {
                        //console.debug("Hide controls");
                        hideControls()
                    }
                }

                function hideControls() {
                    controls.opacity = 0.0
                    pulley.visible = false
                    videoPlayerPage.showNavigationIndicator = false
                }

                function showControls() {
                    controls.opacity = 1.0
                    pulley.visible = true
                    videoPlayerPage.showNavigationIndicator = true
                }

                function pause() {
                    mediaPlayer.pause();
                    if (controls.opacity === 0.0) toggleControls();
                    progressCircle.visible = false;
                    if (! mediaPlayer.seekable) mediaPlayer.stop();
                    onlyMusic.playing = false
                    if (isDash) minPlayer.pause();
                }

                function next() {
                    // reset
                    dataContainer.streamUrl = ""
                    dataContainer.streamTitle = ""
                    videoPoster.player.stop();
                    // before load new
                    dataContainer.streamUrl = mainWindow.modelPlaylist.next() ;
                    mediaPlayer.source = streamUrl
                    videoPauseTrigger();
                    mediaPlayer.play();
                    hideControls();
                }

                function prev() {
                    // reset
                    dataContainer.streamUrl = ""
                    dataContainer.streamTitle = ""
                    videoPoster.player.stop();
                    // before load new
                    dataContainer.streamUrl = mainWindow.modelPlaylist.prev() ;
                    mediaPlayer.source = streamUrl
                    videoPauseTrigger();
                    mediaPlayer.play();
                    hideControls();
                }

                onClicked: {
                    //if (drawer.open) drawer.open = false
                    //else {
                        if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                            //console.debug("Mouse values:" + mouse.x + " x " + mouse.y)
                            var middleX = width / 2
                            var middleY = height / 2
                            //console.debug("MiddleX:" + middleX + " MiddleY:"+middleY + " mouse.x:"+mouse.x + " mouse.y:"+mouse.y)
                            if ((mouse.x >= middleX - Theme.iconSizeMedium && mouse.x <= middleX + Theme.iconSizeMedium) && (mouse.y >= middleY - Theme.iconSizeMedium && mouse.y <= middleY + Theme.iconSizeMedium)) {
                                pause();
                            }
                            else {
                                toggleControls();
                            }
                        } else {
                            //mediaPlayer.play()
                            //console.debug("clicked something else")
                            toggleControls();
                        }
                    //}
                }
                onPressAndHold: {
                    if (onlyMusic.opacity == 1.0) {
                        if (onlyMusic.source == Qt.resolvedUrl("images/audio.png")) {
                            onlyMusic.state = "mc"
                        }
                        else if (onlyMusic.source == Qt.resolvedUrl("images/audio-mc-anim.gif")) {
                            onlyMusic.state = "eq"
                        }
                        else {
                            onlyMusic.state = "default"
                        }
                    }
                }
                onPositionChanged: {
                    if ((enableSubtitles) && (currentVideoSub)) subTitleLoader.item.checkSubtitles()
                }
            }
        }
    }
//    Drawer {
//        id: drawer
//        width: parent.width
//        height: parent.height
//        anchors.bottom: parent.bottom
//        dock: Dock.Bottom
//        foreground: flick
//        backgroundSize: {
//            if (videoPlayerPage.orientation === Orientation.Portrait) return parent.height / 8
//            else return parent.height / 6
//        }
//        background: Rectangle {
//            anchors.fill: parent
//            anchors.bottom: parent.bottom
//            color: Theme.secondaryHighlightColor
//            Button {
//                id: ytDownloadBtn
//                anchors.verticalCenter: parent.verticalCenter
//                anchors.left: parent.left
//                anchors.leftMargin: Theme.paddingMedium
//                text: "Download video"
//                visible: {
//                    if ((/^http:\/\/ytapi.com/).test(streamUrl)) return true
//                    else if (isYtUrl) return true
//                    else return false
//                }
//                // Alternatively use direct youtube url instead of ytapi for downloads (ytapi links not always download with download manager)
//                onClicked: {
//                    // Filter out all chars that might stop the download manager from downloading the file
//                    // Illegal chars: `~!@#$%^&*()-=+\|/?.>,<;:'"[{]}
//                    streamTitle = YT.getDownloadableTitleString(streamTitle)
//                    _ytdl.setUrl(originalUrl);
//                    pageStack.push(Qt.resolvedUrl("ytQualityChooser.qml"), {"streamTitle": streamTitle, "url720p": url720p, "url480p": url480p, "url360p": url360p, "url240p": url240p, "ytDownload": true});
//                    drawer.open = !drawer.open
//                }
//            }
//            Button {
//                id: add2BookmarksBtn
//                anchors.verticalCenter: parent.verticalCenter
//                anchors.right: parent.right
//                anchors.rightMargin: Theme.paddingMedium
//                text : "Add to bookmarks"
//                visible: {
//                    if (streamTitle != "" || streamUrl != "") return true
//                    else return false
//                }
//                onClicked: {
//                    if (streamTitle != "" && !youtubeDirect) mainWindow.modelBookmarks.addBookmark(streamUrl,streamTitle)
//                    else if (streamTitle != "" && youtubeDirect) mainWindow.modelBookmarks.addBookmark(originalUrl,streamTitle)
//                    else if (!youtubeDirect) mainWindow.modelBookmarks.addBookmark(streamUrl,mainWindow.findBaseName(streamUrl))
//                    else mainWindow.modelBookmarks.addBookmark(originalUrl,mainWindow.findBaseName(originalUrl))
//                    drawer.open = !drawer.open
//                }
//            }
//        }

//    }

    children: [

        // Use a black background if not isLightTheme
        Rectangle {
            anchors.fill: parent
            color: isLightTheme ? "white" : "black"
            //visible: video.visible
        },

        VideoOutput {
            id: video
            anchors.fill: parent

            source: Mplayer {
                id: mediaPlayer
                dataContainer: videoPlayerPage
                streamTitle: streamTitle
                streamUrl: streamUrl
                onSourceChanged: if (!isDash)  minPlayer.source = source
                onPositionChanged: if (!isDash) minPlayer.seek(position)
            }

            visible: mediaPlayer.status >= MediaPlayer.Loaded && mediaPlayer.status <= MediaPlayer.EndOfMedia
            width: parent.width
            height: parent.height
            anchors.centerIn: videoPlayerPage

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
                if (title.toString().length !== 0 && !mainWindow.applicationActive) titleHeader.state = "cover";
                else if (streamUrl.toString().length !== 0 && !mainWindow.applicationActive) urlHeader.state = "cover";
            }
        }
    }

    Rectangle {
        width: parent.width
        height: Theme.fontSizeHuge
        y: coverTime.y + 10
        color: isLightColor? "white" : "black"
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
            text: videoDuration
            anchors.left: curPos.right
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeHuge
            font.bold: true
        }
        Label {
            id: curPos
            text: videoPosition + " / "
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeHuge
            font.bold: true
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Space) videoPauseTrigger();
        if (event.key === Qt.Key_Left && mediaPlayer.seekable) {
            mediaPlayer.seek(mediaPlayer.position - 5000)
        }
        if (event.key === Qt.Key_Right && mediaPlayer.seekable) {
            mediaPlayer.seek(mediaPlayer.position + 10000)
        }
    }

    CoverActionList {
        id: coverActionPlay
        enabled: liveView && !isPlaylist

        //        CoverAction {
        //            iconSource: "image://theme/icon-cover-next"
        //        }

        CoverAction {
            iconSource: {
                if (videoPoster.player.playbackState === MediaPlayer.PlayingState) return "image://theme/icon-cover-pause"
                else return "image://theme/icon-cover-play"
            }
            onTriggered: {
                //console.debug("Pause triggered");
                videoPauseTrigger();
                if (!showTimeAndTitle.running) showTimeAndTitle.start();
                else showTimeAndTitle.count = 0;
                videoPoster.hideControls();
            }
        }
    }
    CoverActionList {
        id: coverActionPlayNext
        enabled: liveView && mainWindow.modelPlaylist.isNext() && isPlaylist

        //        CoverAction {
        //            iconSource: "image://theme/icon-cover-next"
        //        }

        CoverAction {
            iconSource: {
                if (videoPoster.player.playbackState === MediaPlayer.PlayingState) return "image://theme/icon-cover-pause"
                else return "image://theme/icon-cover-play"
            }
            onTriggered: {
                //console.debug("Pause triggered");
                videoPauseTrigger();
                if (!showTimeAndTitle.running) showTimeAndTitle.start();
                else showTimeAndTitle.count = 0;
                videoPoster.hideControls();
            }
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-next-song"
            onTriggered: {
                videoPoster.next()
            }
        }
    }

    MprisPlayer {
        id: mprisPlayer

        serviceName: "llsVplayer"

        property string title: streamTitle

        onTitleChanged: {
            if (title != "") {
                console.debug("Title changed to: " + title)
                var metadata = mprisPlayer.metadata
                metadata[Mpris.metadataToString(Mpris.Title)] = title
                mprisPlayer.metadata = metadata
            }
        }

        // Mpris2 Root Interface
        identity: "LLs Video Player"

        // Mpris2 Player Interface
        canControl: true

        canGoNext: true
        canGoPrevious: true
        canPause: true
        canPlay: true
        canSeek: true

        playbackStatus: {
            if (mediaPlayer.playbackState == MediaPlayer.PlayingState) return Mpris.Playing
            else if (mediaPlayer.playbackState == MediaPlayer.PausedState) return Mpris.Paused
            else return Mpris.Stopped
        }
        onPlaybackStatusChanged: {
            mprisPlayer.canGoNext = mainWindow.modelPlaylist.isNext() && isPlaylist
            mprisPlayer.canGoPrevious = mainWindow.modelPlaylist.isPrev() && isPlaylist
            title = streamTitle
        }

        loopStatus: Mpris.None
        shuffle: false
        volume: 1

        onPauseRequested: {
            videoPoster.pause();
        }
        onPlayRequested: {
            videoPoster.play();
        }
        onPlayPauseRequested: {
            videoPlayerPage.videoPauseTrigger();
        }
        onStopRequested: {
            videoPoster.player.stop();
        }
        onNextRequested: {
            videoPoster.next();
        }
        onPreviousRequested: {
            videoPoster.prev();
        }
        onSeekRequested: {
            mediaPlayer.seek(offset);
        }
    }
}
