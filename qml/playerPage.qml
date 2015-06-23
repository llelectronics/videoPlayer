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

import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.Page {
    id: videoPlayerPage

    Rectangle {
	anchors.fill: parent
	color: "black"
    }

    Video {
    	id: videoWindow
    	anchors.fill: parent
        source: "/home/llelectronics/Videos/test.m4v"
        onDurationChanged: timeLine.maximumValue = duration / 1000
        onPositionChanged: timeLine.value = position / 1000
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
