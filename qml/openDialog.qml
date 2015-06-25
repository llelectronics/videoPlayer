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

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0
import org.kde.plasma.extras 2.0
import Qt.labs.folderlistmodel 2.1


PlasmaComponents.Page {
    id: page

    function openFile(path) {
	mainWindow.loadPlayer("",path);
    }

    FolderListModel {
        id: fileModel
        folder: videoPath 
        showDirsFirst: true
        showDotAndDotDot: true // TODO: good default or should be configurable ?
        showOnlyReadable: true
    }

    ListView {
        id: view
        model: fileModel
        anchors.fill: parent

        header: Heading {
        	id: header
        	text: qsTr("Open File")
        	font.bold: true
        	level: 2
        	//anchors.top: parent.top
        	//anchors.left: parent.left
        	//anchors.margins: parent.width / 32
        } 

        PlasmaComponents.ToolButton {
		id: videoBtn
        	parent: mainWindow.mainToolbar
        	iconName: "folder-videos"
        	//text: "Show Video Folder" // We don't that do we ?
        	tooltip: "Show Video Folder" 
                onClicked: fileModel.folder = videoPath
                visible: page.status == PlasmaComponents.PageStatus.Active
	}

        PlasmaComponents.ToolButton {
		id: homeBtn
        	parent: mainWindow.mainToolbar
        	iconName: "user-home"
        	//text: "Show Home" // We don't that do we ?
        	tooltip: "Show Home" 
                onClicked: fileModel.folder = homePath
                visible: page.status == PlasmaComponents.PageStatus.Active
	}

        PlasmaComponents.ToolButton {
		id: rootBtn
        	parent: mainWindow.mainToolbar
        	iconName: "folder-red"
        	//text: "Show Filesystem Root" // We don't that do we ?
        	tooltip: "Show Filesystem Root" 
                onClicked: fileModel.folder = "/";
                visible: page.status == PlasmaComponents.PageStatus.Active
	}

        delegate: PlasmaComponents.ListItem {
            id: delegate
            width: parent.width
            enabled: true

            Column {
                width: parent.width

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.largeSpacing
                    text: fileName + (fileIsDir ? "/" : "")
                }

                Label {
                    visible: !fileIsDir
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    text: fileSize + ", " + fileModified
                    color: theme.linkColor
                }
            }

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
        PlasmaComponents.ScrollBar {
		id: scrollBar
		flickableItem: view
		anchors.right: parent.right
                width: parent.width / 64
		interactive: true
	}
    }
}
