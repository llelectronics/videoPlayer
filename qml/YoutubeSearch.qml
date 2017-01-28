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

import QtQuick 2.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import QtMultimedia 5.0

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0
import org.kde.kirigami 1.0 as Kirigami

import "helper/yt.js" as YT

Kirigami.Page {
	leftPadding: 0
	rightPadding: 0
	bottomPadding: 0
	topPadding: 0
	
	title: "Youtube"
	id: searchResultsDialog
	property string searchTerm
	property bool ytDetect: true
	property string websiteUrl: "http://m.youtube.com/"
	property string searchUrl: "http://m.youtube.com/results?q="
	property string uA: "Mozilla/5.0 (Linux; U; Android 2.3; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"


	WebView {
		id: ytView
		anchors.centerIn: parent
		// Width and height for scale=2.0
		//                width: searchResultsDialog.orientation === Orientation.Portrait ? Screen.width / 2 : (Screen.height - 100) / 2
		//                height: Screen.height / 2
		focus: true
		anchors.fill: parent

		experimental.userAgent: uA
		experimental.userScripts: [Qt.resolvedUrl("helper/userscript.js")]

		onNavigationRequested: {
			//console.debug("[SecondPage.qml] Request navigation to " + request.url)
			if (YT.checkYoutube(request.url.toString()) === true && ytDetect === true) {
				if (YT.getYtID(request.url.toString()) != "") {
					//console.debug("[SecondPage.qml] Youtube Link detected")
					request.action = WebView.IgnoreRequest;
					mainWindow.isYtUrl = true;
					var yttitle = YT.getYoutubeTitle(request.url.toString());
			var ytID = YT.getYtID(request.url.toString());
					YT.getYoutubeStream(ytID);
					mainWindow.showPlayer();
					ytView.reload(); // WTF why is this working with IgnoreRequest

				} else { request.action = WebView.AcceptRequest; }
			}
			else {
				request.action = WebView.AcceptRequest;
			}
		}

		Component.onCompleted: url = websiteUrl

//         Rectangle {
//             anchors.left: parent.left
//             anchors.bottom: parent.bottom
//             visible: ytView.canGoBack
//             width: parent.width / 8
//             height: parent.height / 16
//             gradient: Gradient {
//                 GradientStop { position: 1.0; color: "black" }
//                 GradientStop { position: 0.0; color: "transparent" } //Theme.highlightColor} // Black seems to look and work better
//             }
//             IconItem {
//                 id: backBtn
//                 source: "arrow-left"
//                 enabled: ytView.canGoBack
//                 visible: ytView.canGoBack
//                 anchors.centerIn: parent
//                 MouseArea {
//                     anchors.fill: parent
//                     onClicked: {
//                         ytView.goBack();
//                     }
//                 }
//             }
//         }
	}
}
