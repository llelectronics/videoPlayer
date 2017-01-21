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
import org.kde.kirigami 1.0 as Kirigami
import Qt.labs.folderlistmodel 2.1


Kirigami.Page {
	id: page
	title: qsTr("Open URL")

	function openUrl(path) {
		mainWindow.loadPlayer("",path);
	}

	PlasmaComponents.TextField {
		id: urlField
		clearButtonShown: true
		placeholderText: qsTr("Enter a streaming url starting with 'http://' or similar")
		width: parent.width / 1.15
		height: units.gridUnit * 2
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: header.bottom
		anchors.topMargin: units.largeSpacing
	}
	
	PlasmaComponents.ListItem {
		height: units.gridUnit * 2
		width: urlField.width
		anchors.margins: units.gridUnit
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: urlField.bottom
		enabled: true
		
		IconItem {
			id: openIcon
			width: units.gridUnit * 2
			height: width
			source: "dialog-ok"
			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
				margins: units.gridUnit
				rightMargin: 0
			}
		}
		
		Heading {
			id: openLbl
			text: qsTr("Load Url")
			elide: Text.ElideRight
			anchors.verticalCenter: parent.verticalCenter
			anchors.right: parent.right
			level: 4
		}
		
		onClicked: {
			openUrl(urlField.text)
		}
	}
}
