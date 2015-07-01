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

PlasmaComponents.Page {
    id: aboutPage
    
    Flickable {
        id: flick
        width:parent.width
        height: parent.height
        anchors.top: parent.top
        contentHeight: column1.height
        
        Column{
            id: column1
            width: parent.width
            spacing: 15
            
            Image{
                source: mainWindow.appIcon
                height: 128
                width: 128
                fillMode: Image.PreserveAspectFit
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }
            PlasmaComponents.Label {
                font.bold: true
                text: mainWindow.appName+" v"+mainWindow.version
                anchors.horizontalCenter: parent.horizontalCenter
                
            }
            PlasmaComponents.Label {
                text: "License: LGPLv2"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Rectangle{
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#333333" }
                    GradientStop { position: 1.0; color: "#777777" }
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                height: 3
                width: parent.width-64
            }
            
            PlasmaComponents.Label {
                width: 360
                font.bold: true
                text: "Created by llelectronics"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
            }
            Rectangle{
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#333333" }
                    GradientStop { position: 1.0; color: "#777777" }
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                height: 3
                width: parent.width-64
            }
            
            PlasmaComponents.Button {
                id: homepage
                anchors.horizontalCenter: parent.horizontalCenter
                text: "<a href=\"https://github.com/llelectronics/\">Sourcecode on Github</a>"
                onClicked: {
                    Qt.openUrlExternally("https://github.com/llelectronics/videoPlayer/tree/plasma");
                }
            }
            
            PlasmaComponents.Label {
                width: parent.width-70
                text: qsTr("A simple videoplayer based on gstreamer.")
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
                height: 200
                wrapMode: Text.WordWrap
            }
        }
    }
    
    
}
