/*
 * Copyright (C) 2014-2015 Leszek Lesner <leszek@zevenos.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) version 3, or any
 * later version accepted by the membership of KDE e.V. (or its
 * successor approved by the membership of KDE e.V.), which shall
 * act as a proxy defined in Section 6 of version 3 of the license.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Window 2.1
import QtMultimedia 5.0
import "helper/timeFormat.js" as TimeHelper
import "helper/db.js" as DB

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0
import org.kde.kirigami 1.0 as Kirigami

Kirigami.Page {
    id: videoPlayerPage
    title: {
        if (title != "") return title
        else if (streamTitle != "") return streamTitle
        else return streamUrl
    }
 
    property string originalUrl: mainWindow.originalUrl
    property string streamUrl: mainWindow.streamUrl
    property bool isYtUrl: mainWindow.isYtUrl
    property string streamTitle: mainWindow.streamTitle
    property string artist: videoWindow.metaData.albumArtist ? videoWindow.metaData.albumArtist : ""
    property int subtitlesSize: mainWindow.subtitlesSize
    property bool boldSubtitles: mainWindow.boldSubtitles
    property string subtitlesColor: mainWindow.subtitlesColor
    property bool enableSubtitles: mainWindow.enableSubtitles
    property variant currentVideoSub: []
    property string url720p: mainWindow.url720p
    property string url480p: mainWindow.url480p
    property string url360p: mainWindow.url360p
    property string url240p: mainWindow.url240p
    property string ytQual: mainWindow.ytQual
    property bool autoplay: mainWindow.autoplay
    
    actions {
        main: Action {
            iconName: { 
                if (videoWindow.playbackState != MediaPlayer.PlayingState) return "media-playback-start"
                else return "media-playback-pause"
            }
            onTriggered: {
                if (videoWindow.playbackState != MediaPlayer.PlayingState) videoWindow.play()
                else videoWindow.pause()
            }
        }
        left: Action {
            iconName: "view-fullscreen"
            onTriggered: toggleControls()
        }
        right: Action {
            iconName: "media-playback-stop"
            onTriggered: {
                // applicationWindow().pageStack.pop;
                videoWindow.stop();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    IconItem {
        id: onlyAudioIcon
        source: "audio-x-generic"
        anchors.centerIn: parent
        width: parent.width / 2
        height: width
        visible: !videoWindow.hasVideo
    }

    function showControls() {
        timeLine.visible = true;
        timeLineLbl.visible = true;
        applicationWindow().controlsVisible = true;
    }

    function hideControls() {
        timeLine.visible = false;
        timeLineLbl.visible = false;
        applicationWindow().controlsVisible = false;
    }

    function toggleControls() {
        if (timeLine.visible && applicationWindow().controlsVisible) 
            hideControls();
        else if (!timeLine.visible && !applicationWindow().controlsVisible) 
            showControls();	
    }
    
    onStreamUrlChanged: {
	// TODO: maybe youtube or other url checks
        videoWindow.source = streamUrl
        //Write into history database
        DB.addHistory(streamUrl,videoPlayerPage.title);
        // Don't forgt to write it to the List aswell
        mainWindow.add2History(streamUrl,videoPlayerPage.text);
    }

    Video {
    	id: videoWindow
    	anchors.fill: parent
        onDurationChanged: timeLine.maximumValue = duration / 1000
        onPositionChanged: timeLine.value = position / 1000
        MouseArea {
            anchors.fill: parent
            onClicked: toggleControls()
            }
        onStopped: applicationWindow().controlsVisible = true
        }

    Kirigami.Label {
        id: timeLineLbl
        text: TimeHelper.formatTime(timeLine.value) + "/" + TimeHelper.formatTime(timeLine.maximumValue)
        anchors.bottom: videoWindow.bottom
        anchors.right: videoWindow.right
    }
    
    Slider {
        id: timeLine
        minimumValue: 0
        value: 0
        stepSize: 1.0
        width: parent.width
        onPressedChanged: {
                if (!pressed) {
                if (videoWindow.seekable) videoWindow.seek(value * 1000)
                }
        }
    }
}