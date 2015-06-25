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
import QtQuick.Controls 1.0
import QtQuick.Window 2.1
import QtMultimedia 5.0
import "helper/timeFormat.js" as TimeHelper
import "helper/db.js" as DB

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0

PlasmaComponents.Page {
    id: videoPlayerPage
 
    property string originalUrl: mainWindow.originalUrl
    property string streamUrl: mainWindow.streamUrl
    property bool isYtUrl: mainWindow.isYtUrl
    property string streamTitle: mainWindow.streamTitle
    property string title: videoWindow.metaData.title ? videoWindow.metaData.title : ""
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
	headerTitle.visible = true;
	mainWindow.mainToolbar.parent.parent.visible = true;
    }

    function hideControls() {
	headerTitle.visible = false;
	mainWindow.mainToolbar.parent.parent.visible = false;
    }

    function toggleControls() {
	if (headerTitle.visible && mainWindow.mainToolbar.parent.parent.visible) 
		hideControls();
	else if (!headerTitle.visible && !mainWindow.mainToolbar.parent.parent.visible) 
		showControls();	
    }

    onStreamUrlChanged: {
	// TODO: maybe youtube or other url checks
        videoWindow.source = streamUrl
        //Write into history database
        DB.addHistory(streamUrl,headerTitle.text);
        // Don't forgt to write it to the List aswell
        mainWindow.add2History(streamUrl,headerTitle.text);
    }

    Rectangle {
	id: headerTitle
	anchors.top: parent.top
	anchors.left: parent.left
	width: parent.width
	height: parent.height / 32
        color: theme.backgroundColor
        PlasmaComponents.Label {
                anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left
		anchors.leftMargin: units.smallSpacing
		text: {
			if (title != "") return title
			else if (streamTitle != "") return streamTitle
			else return streamUrl
		}
	}
    }

    Video {
    	id: videoWindow
    	anchors.fill: parent
        source: "/home/llelectronics/Videos/test.m4v"
        onDurationChanged: timeLine.maximumValue = duration / 1000
        onPositionChanged: timeLine.value = position / 1000
        MouseArea {
		anchors.fill: parent
		onClicked: toggleControls()
	}
        onStopped: showControls()
    }

    PlasmaComponents.Label {
        id: timeLineLbl
	text: TimeHelper.formatTime(timeLine.value) + "/" + TimeHelper.formatTime(timeLine.maximumValue)
        parent: mainWindow.mainToolbar
    }
    
    PlasmaComponents.Slider {
	id: timeLine
        parent: mainWindow.mainToolbar
	minimumValue: 0
        value: 0
        stepSize: 1.0
        width: parent.width - stopBtn.width * 5 // We have 3 buttons + timelinelbl in toolbar
        onPressedChanged: {
                if (!pressed) {
			if (videoWindow.seekable) videoWindow.seek(value * 1000)
                }
	}
    }

    PlasmaComponents.ToolButton {
        id: stopBtn
        parent: mainWindow.mainToolbar
    	iconName: "media-playback-stop"
    	//text: "Back" // We don't that do we ?
    	onClicked: videoWindow.stop()
    }

    PlasmaComponents.ToolButton {
        id: playBtn
        parent: mainWindow.mainToolbar
    	iconName: { 
		if (videoWindow.playbackState != MediaPlayer.PlayingState) return "media-playback-start"
                else return "media-playback-pause"
        }
    	//text: "Back" // We don't that do we ?
    	onClicked: { 
		if (videoWindow.playbackState != MediaPlayer.PlayingState) videoWindow.play()
                else videoWindow.pause()
        }
    }
}
