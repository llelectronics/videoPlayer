import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import org.nemomobile.thumbnailer 1.0
import QtGraphicalEffects 1.0
import "yt.js" as YT

MouseArea {
    id: videoItem

    property MediaPlayer player
    property bool active
    property url source
    property string mimeType
    property int duration
    property int pressTime: 1
    onDurationChanged: positionSlider.maximumValue = duration
    property alias controls: controls
    property alias position: positionSlider.value
    signal playClicked;
    signal nextClicked;
    signal prevClicked;

    property bool transpose

    property bool playing: active && videoItem.player && videoItem.player.playbackState == MediaPlayer.PlayingState
    readonly property bool _loaded: active
                                    && videoItem.player
                                    && videoItem.player.status >= MediaPlayer.Loaded
                                    && videoItem.player.status < MediaPlayer.EndOfMedia
    property alias _pressTimer: pressTimer

    implicitWidth: poster.implicitWidth
    implicitHeight: poster.implicitHeight

    function ffwd(seconds) {
        ffwdRewRectAnim.secs = seconds
        ffwdRewRectAnim.isRew = false
        ffwdRewAnim.start()
        videoItem.player.seek((positionSlider.value*1000) + (seconds * 1000))
    }

    function rew(seconds) {
        ffwdRewRectAnim.secs = seconds
        ffwdRewRectAnim.isRew = true
        ffwdRewAnim.start()
        videoItem.player.seek((positionSlider.value*1000) - (seconds * 1000))
    }

    SequentialAnimation {
        id: ffwdRewAnim
        PropertyAction { target: ffwdRewRectAnim; property: "visible"; value: true }
        NumberAnimation { target: ffwdRewRectAnim; property: "opacity"; to: 1; duration: 200 }
        NumberAnimation { target: ffwdRewRectAnim; property: "opacity"; to: 0; duration: 200 }
        PropertyAction { target: ffwdRewRectAnim; property: "visible"; value: false }
    }

    Rectangle {
        id: ffwdRewRectAnim

        property int secs: 10
        property bool isRew: false

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        anchors.right: isRew? undefined : parent.right
        anchors.left: isRew ? parent.left : undefined
        color: Theme.backgroundGlowColor
        visible: false
        opacity: 0

        Label {
            anchors.centerIn: parent
            text: parent.isRew ? parent.secs + " <<" : ">> " + parent.secs
            font.pixelSize: Theme.fontSizeExtraLarge
        }
    }

    Connections {
        target: videoItem._loaded ? videoItem.player : null

        onPositionChanged: positionSlider.value = videoItem.player.position / 1000
        onDurationChanged: positionSlider.maximumValue = videoItem.player.duration / 1000
    }

    onActiveChanged: {
        if (!active) {
            positionSlider.value = 0
        }
    }

    // Poster
    Thumbnail {
        id: poster

        anchors.centerIn: parent


        width: !videoItem.transpose ? videoItem.width : videoItem.height
        height: !videoItem.transpose ? videoItem.height : videoItem.width

        sourceSize.width: Screen.height
        sourceSize.height: Screen.height

        source: videoItem.source
        mimeType: videoItem.mimeType

        priority: Thumbnail.HighPriority
        fillMode: Thumbnail.PreserveAspectFit
        opacity: !videoItem._loaded ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation { id: posterFade } }

        visible: !videoItem._loaded || posterFade.running

        rotation: videoItem.transpose ? (implicitHeight > implicitWidth ? 270 : 90)  : 0
    }

    Item {
        id: controls
        width: videoItem.width
        height: videoItem.height
        property alias rew: rewRec
        property alias ffwd: ffwdRec

        opacity: 1.0
        Behavior on opacity { FadeAnimation { id: controlFade } }

        visible: videoItem.player || controlFade.running //(!videoItem.playing || controlFade.running)

        Rectangle {
            anchors.centerIn: parent
            width: playPauseImg.width + Theme.iconSizeMedium
            height: playPauseImg.height + Theme.iconSizeMedium
            color: isLightTheme ? "white" : "black"
            opacity: 0.4
            radius: width / 2
            border.color: isLightTheme ? "black" : "white"
            border.width: 2
        }

        Rectangle {
            id: ffwdRec
            anchors.centerIn: ffwdImg
            width: playPauseImg.width + Theme.iconSizeSmall
            height: playPauseImg.height + Theme.iconSizeSmall
            color: isLightTheme ? "white" : "black"
            opacity: 0.4
            radius: width / 2
            border.color: isLightTheme ? "black" : "white"
            border.width: 2
        }

        Rectangle {
            id: rewRec
            anchors.centerIn: rewImg
            width: playPauseImg.width + Theme.iconSizeSmall
            height: playPauseImg.height + Theme.iconSizeSmall
            color: isLightTheme ? "white" : "black"
            opacity: 0.4
            radius: width / 2
            border.color: isLightTheme ? "black" : "white"
            border.width: 2
        }

        Image {
            id: playPauseImg
            anchors.centerIn: parent
            source: {
                if (videoItem.player && (!videoItem.playing)) return "image://theme/icon-cover-play"
                else return "image://theme/icon-cover-pause"
            }
            width: Theme.iconSizeMedium
            height: width
            MouseArea {
                anchors.centerIn: parent
                width: parent.width + Theme.iconSizeMedium
                height: parent.height + Theme.iconSizeMedium
                enabled: !videoItem.playing
                onClicked: {
                    //console.debug("VideoItem.source length = " + videoItem.source.toString().length)
                    if (videoItem.source.toString().length !== 0) {
                        //console.debug("Yeah we have a video source")
                        videoItem.playClicked();
                    }
                }
            }
        }

        Timer {
            id: pressTimer
            running: false;
            interval: 1500
            onTriggered: { stop() }
            triggeredOnStart: false
        }

        Image {
            id: ffwdImg
            anchors.verticalCenter: playPauseImg.verticalCenter
            anchors.left: playPauseImg.right
            anchors.leftMargin: Theme.paddingLarge * 2 + Theme.paddingMedium
            source: "image://theme/icon-m-enter-accept"
            width: Theme.iconSizeMedium
            height: width
            MouseArea {
                anchors.centerIn: parent
                width: parent.width + Theme.iconSizeMedium
                height: parent.height + Theme.iconSizeMedium
                enabled: { if (controls.opacity == 1.0) return true; else return false; }
                onClicked: {
                    //console.debug("VideoItem.source length = " + videoItem.source.toString().length)
                    if (videoItem.source.toString().length !== 0) {
                        //console.debug("Yeah we have a video source")
                        if (!pressTimer.running) {
                            pressTime = 1;
                            pressTimer.start();
                            ffwd(10)
                        }
                        else {
                            pressTime += 1
                            forwardIndicator.visible = true
                            ffwd(10*pressTime)
                        }
                    }
                }
                onPressAndHold: {
                    nextClicked();
                }
            }
        }

        Image {
            id: rewImg
            anchors.verticalCenter: playPauseImg.verticalCenter
            anchors.right: playPauseImg.left
            anchors.rightMargin: Theme.paddingLarge * 2 + Theme.paddingMedium
            source: "image://theme/icon-m-enter-accept"
            width: Theme.iconSizeMedium
            height: width
            mirror: true
            MouseArea {
                anchors.centerIn: parent
                width: parent.width + Theme.iconSizeMedium
                height: parent.height + Theme.iconSizeMedium
                enabled: { if (controls.opacity == 1.0) return true; else return false; }
                onClicked: {
                    //console.debug("VideoItem.source length = " + videoItem.source.toString().length)
                    if (videoItem.source.toString().length !== 0) {
                        //console.debug("Yeah we have a video source")
                        if (!pressTimer.running) {
                            pressTime = 1;
                            pressTimer.start();
                            rew(5)
                        }
                        else {
                            pressTime += 1
                            backwardIndicator.visible = true
                            rew(5*pressTime)
                        }
                    }
                }
                onPressAndHold: {
                    prevClicked();
                }
            }
        }

        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            enabled: { if (controls.opacity == 1.0) return true; else return false; }
            height: Theme.itemSizeMedium + (2 * Theme.paddingLarge)
            //color: "black"
            //opacity: 0.5
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: isLightTheme ? "white" : "black" } //Theme.highlightColor} // Black seems to look and work better
            }


            BackgroundItem {
                id: qualBtn
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.paddingMedium
                width: height
                height: Theme.itemSizeSmall
                visible: {
                    if (firstPage.ytQual != "") return true
                    else return false
                }
                onClicked: {
                    videoItem.player.pause()
                    var youtubeID = YT.getYtID(firstPage.originalUrl.toString())
                    if (youtubeID !== "") {
                        _ytdl.setUrl(youtubeID);
                    }
                    pageStack.push(Qt.resolvedUrl("../ytQualityChooser.qml"), {"streamTitle": firstPage.streamTitle, "url720p": firstPage.url720p, "url480p": firstPage.url480p, "url360p": firstPage.url360p, "url240p": firstPage.url240p});
                }
                Label {
                    text: firstPage.ytQual
                    color: parent.highlighted ? Theme.highlightColor : isLightTheme ? "black" : "white"
                    anchors.centerIn: parent
                    style: Text.Outline
                    styleColor: isLightTheme? "black" : "white"
                }
            }
            BackgroundItem {
                id: aspectBtn
                anchors.right: qualBtn.visible ? qualBtn.left : parent.right
                anchors.rightMargin: Theme.paddingMedium
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.paddingMedium
                width: height
                height: Theme.iconSizeMedium
                visible: allowScaling
                onClicked: {
                    toggleAspectRatio();
                }
                Image {
                    source: "image://theme/icon-m-scale"
                    anchors.fill: parent
                }
            }
            Label {
                id: maxTime
                anchors.right: {
                    if (aspectBtn.visible) return aspectBtn.left
                    else if (qualBtn.visible) return qualBtn.left
                    else return parent.right
                }
                anchors.rightMargin: qualBtn.visible || aspectBtn.visible ? Theme.paddingMedium : (2 * Theme.paddingLarge)
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.paddingLarge
                text: {
                    if (positionSlider.maximumValue > 3599) return Format.formatDuration(positionSlider.maximumValue, Formatter.DurationLong)
                    else return Format.formatDuration(positionSlider.maximumValue, Formatter.DurationShort)
                }
                visible: videoItem._loaded
            }

            BackgroundItem {
                id: repeatBtn
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.paddingMedium
                width: height
                height: Theme.iconSizeMedium
                onClicked: {
                    isRepeat = !isRepeat
                }
                Image {
                    source: isRepeat ? "image://theme/icon-m-repeat" : "image://theme/icon-m-forward"
                    anchors.fill: parent
                }
            }

            BackgroundItem {
                id: castBtn
                anchors.left: repeatBtn.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.paddingMedium
                width: height
                visible: jupii.found
                height: Theme.iconSizeMedium
                onClicked: {
                    jupii.addUrlOnceAndPlay(streamUrl.toString(), streamTitle, "", (onlyMusic.visible ? 1 : 2), "llsvplayer", "/usr/share/icons/hicolor/172x172/apps/harbour-videoPlayer.png")
                }
                Image {
                    source: "../images/icon-m-cast.png"
                    anchors.fill: parent
                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: "black"
                        visible: isLightTheme
                    }
                }
            }

            Slider {
                id: positionSlider

                anchors {
                    left: castBtn.visible ? castBtn.right : repeatBtn.right
                    right: {
                        if (maxTime.visible) maxTime.left
                        else if (qualBtn.visible) qualBtn.left
                        else parent.right;
                    }
                    bottom: parent.bottom
                }
                anchors.bottomMargin: Theme.paddingLarge + Theme.paddingMedium
                enabled: { if (controls.opacity == 1.0) return true; else return false; }
                height: Theme.itemSizeMedium
                width: {
                    var slidWidth = parent.width
                    if (qualBtn.visible) slidWidth =- qualBtn.width
                    if (maxTime.visible) slidWidth =- maxTime.width
                    if (aspectBtn.visible) slidWidth =- aspectBtn.width
                    return slidWidth
                }
                handleVisible: down ? true : false
                minimumValue: 0

                valueText: {
                    if (value > 3599) return Format.formatDuration(value, Formatter.DurationLong)
                    else return Format.formatDuration(value, Formatter.DurationShort)
                }
                onReleased: {
                    if (videoItem.active) {
                        videoItem.player.source = videoItem.source
                        videoItem.player.seek(value * 1000)
                        //videoItem.player.pause()
                    }
                }
                onDownChanged: {
                    if (down) {
                        coverTime.visible = true
                    }
                    else
                        coverTime.fadeOut.start()
                }
            }
        } // Bottom rect End
        Row {
            id: backwardIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.width / 2 - (playPauseImg.height + Theme.paddingLarge)
            visible: false
            spacing: -Theme.paddingLarge*2

            Image {
                id: prev1
                width: Theme.itemSizeLarge
                height: Theme.itemSizeLarge
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                source: "image://theme/icon-cover-play"

                transform: Rotation{
                    angle: 180
                    origin.x: prev1.width/2
                    origin.y: prev1.height/2
                }
            }
            Image {
                id: prev2
                width: Theme.itemSizeLarge
                height: Theme.itemSizeLarge
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                source: "image://theme/icon-cover-play"

                transform: Rotation{
                    angle: 180
                    origin.x: prev2.width/2
                    origin.y: prev2.height/2
                }
            }

            Timer {
                id: hideBackward
                interval: 300
                onTriggered: backwardIndicator.visible = false
            }

            onVisibleChanged: if (backwardIndicator.visible) hideBackward.start()
        }

        Row {
            id: forwardIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.width / 2 - (playPauseImg.height + Theme.paddingLarge)
            visible: false
            spacing: -Theme.paddingLarge*2

            Image {
                width: Theme.itemSizeLarge
                height: Theme.itemSizeLarge
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                source: "image://theme/icon-cover-play"

            }
            Image {
                width: Theme.itemSizeLarge
                height: Theme.itemSizeLarge
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                source: "image://theme/icon-cover-play"
            }

            Timer {
                id: hideForward
                interval: 300
                onTriggered: forwardIndicator.visible = false
            }

            onVisibleChanged: if (forwardIndicator.visible) hideForward.start()
        }
    }
}
