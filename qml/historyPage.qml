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
import org.kde.plasma.extras 2.0

PlasmaComponents.Page {
    id: historyPage
    
    Heading {
        id: header
	text: qsTr("History")
	font.bold: true
	level: 2
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: parent.width / 32
    } 

    ListView {
        anchors.top: header.bottom
        width: parent.width
        height: parent.height - header.height
	model: mainWindow.historyModel
        delegate: PlasmaComponents.ListItem {
                width: parent.width - (parent.width / 32)
                anchors.centerIn: parent
		onClicked: { 
			console.debug("Clicked " + htitle + " with url: " + hurl)
			mainWindow.loadPlayer(htitle,hurl)
		}
                enabled: true
		PlasmaComponents.Label {
                	anchors.left: parent.left
                	anchors.right: parent.right
                	height: implicitHeight

                	elide: Text.ElideRight
                	text: model.htitle
                }
	}
    }
}
