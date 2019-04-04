import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import org.nemomobile.mpris 1.0

DockedPanel {
    id: minPlayerPanel
    parent: pageStack.currentPage

    width: parent.width
    height: Theme.itemSizeExtraLarge + Theme.paddingLarge

    dock: Dock.Bottom

    function prev() {
        minPlayer.stop();
        minPlayer.source = modelPlaylist.prev();
        minPlayer.play();
    }

    function next() {
        minPlayer.stop();
        minPlayer.source = modelPlaylist.next();
        minPlayer.play();
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.overlayBackgroundColor
        opacity: 0.8
        SwipeArea {
            anchors.fill: parent
            onSwipeDown: minPlayerPanel.hide()
        }
    }

    Label {
        id: mediaTitle
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingSmall
        anchors.horizontalCenter: parent.horizontalCenter
        truncationMode: TruncationMode.Fade
        text: minPlayer.streamTitle
        width: parent.width - 2 * Theme.paddingLarge
        horizontalAlignment: (contentWidth > width) ? Text.AlignLeft : Text.AlignHCenter
    }

    Label {
        id: playTime
        anchors.top: mediaTitle.bottom
        anchors.topMargin: Theme.paddingSmall / 6
        property string pos: {
            if ((minPlayer.position / 1000) > 3599) Format.formatDuration(minPlayer.position / 1000, Formatter.DurationLong)
            else return Format.formatDuration(minPlayer.position / 1000, Formatter.DurationShort)
        }
        property string dur: {
            if ((minPlayer.duration / 1000) > 3599) Format.formatDuration(minPlayer.duration / 1000, Formatter.DurationLong)
            else return Format.formatDuration(minPlayer.duration / 1000, Formatter.DurationShort)
        }
        text: pos + " / " + dur;
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeExtraSmall
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: playTime.bottom
        anchors.topMargin: Theme.paddingSmall / 4
        IconButton {
            icon.source: "image://theme/icon-m-previous"
            visible: minPlayer.isPlaylist && modelPlaylist.isPrev();
            onClicked: {
                prev();
            }
        }
        IconButton {
            icon.source: minPlayer.isPlaying ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
            onClicked: {
                //console.debug("isPlayling: " + minPlayer.isPlaying)
                if (minPlayer.isPlaying)
                {
                    //console.debug("Pause")
                    minPlayer.pause()
                }
                else {
                    //console.debug("Play")
                    minPlayer.play()
                }
            }
        }
        IconButton {
            icon.source: "image://theme/icon-m-next"
            visible: minPlayer.isPlaylist && modelPlaylist.isNext();
            onClicked: {
                next();
            }
        }
    }
    Component.onCompleted: {
        mprisPlayer.canControl = true;
        if (minPlayer.playbackState == MediaPlayer.PlayingState) mprisPlayer.playbackStatus = Mpris.Playing
        else mprisPlayer.playbackStatus = Mpris.Paused
    }

    Connections {
        target: mprisPlayer
        onPauseRequested: {
            minPlayer.pause();
        }
        onPlayRequested: {
            minPlayer.play();
        }
        onPlayPauseRequested: {
           if (minPlayer.playbackState == MediaPlayer.PlayingState) mprisPlayer.pause();
           else mprisPlayer.play();
        }
        onStopRequested: {
            minPlayer.stop();
        }
        onNextRequested: {
            next();
        }
        onPreviousRequested: {
            prev();
        }
        onSeekRequested: {
            minPlayer.seek(offset);
        }
    }
}

