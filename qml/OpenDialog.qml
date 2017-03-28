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
import org.kde.kirigami 2.0 as Kirigami
import Qt.labs.folderlistmodel 2.2

Kirigami.ScrollablePage {
	id: page
	title: qsTr("Open File")
	
	function openFile(path) {
		mainWindow.loadPlayer("",path);
	}
	
	actions {
		main: Kirigami.Action {
			id: parentFolderButton
			tooltip: qsTr("go to parent folder")
			iconName: "go-parent-folder"
			onTriggered: fileModel.folder = fileModel.parentFolder
			enabled: true
		}
		contextualActions: [
			Kirigami.Action {
				text: qsTr("Go to file system root")
				iconName: "folder-red"
				onTriggered: fileModel.folder = "/"
			},
			Kirigami.Action {
				iconName: "folder-videos"
				text: qsTr("Show Video Folder")
				onTriggered: fileModel.folder = videoPath                
			},
			Kirigami.Action {
				iconName: "user-home"
				text: qsTr("Show Home")
				onTriggered: fileModel.folder = homePath
			},
			Kirigami.Action {
				text: qsTr("View sounds")
				iconName: "folder-sound"
				onTriggered: fileModel.nameFilters = ["*.mp3", "*.wav", "*.ogg", "*.webm", "*.flac", "*.3ga", "*.aac", ".*.mpa", ".*.wma"]
			},
			Kirigami.Action {
				text: qsTr("View Videos")
				iconName: "folder-video"
				onTriggered: fileModel.nameFilters = ["*.mkv", "*.mp4", "*.ogv", "*.webm", "*.264", "*.avi", "*.h264", "*.wmv", "*.mpg4", "*.3gp*"]
			}
		]
	}
	
	FolderListModel {
		id: fileModel
		folder: videoPath
		showDirsFirst: true
		showDotAndDotDot: false // replaced by the main action Button
		showOnlyReadable: true
		nameFilters: [ "*"]
	}

	ListView {
		id: view
		model: fileModel
		anchors.fill: parent

		delegate: Kirigami.BasicListItem {
			width: parent.width
			reserveSpaceForIcon: true

			icon: (fileIsDir ? "folder" : "text-x-plain")
			label: fileName + (fileIsDir ? "/" : "")

			onClicked: {
				if (fileIsDir) {
					if (fileName === "..") fileModel.folder = fileModel.parentFolder
					else if (fileName === ".") return
					else fileModel.folder = filePath
				} else {
					openFile(filePath)
				}
			}
		}
	}
}
