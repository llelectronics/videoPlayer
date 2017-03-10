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
import QtQuick.Controls 2.0
import QtQuick.Window 2.1
import org.kde.kirigami 2.0 as Kirigami

import "helper/db.js" as DB

Kirigami.ApplicationWindow {
	id: mainWindow
	width: 540
	height: 960
	visible: true
	
	property string appIcon: "/usr/share/icons/hicolor/64x64/apps/vplayer.png" //TODO: use xdg somehow
	property string appName: "LLs vPlayer"
	property string version: "0.2"
	property alias historyModel: historyModel

	// Settings /////////////////////////////////////////
	property string openDialogType: "adv"
	property bool enableSubtitles: true
	property int subtitlesSize: 25
	property bool boldSubtitles: false
	property string subtitlesColor: "white"
	property bool youtubeDirect: true           
	/////////////////////////////////////////////////////

	// Videoplayer properties //////////////////////////
	property string originalUrl
	property string streamUrl
	property bool isYtUrl: false
	property bool autoplay: false
	property string streamTitle
	property string url720p
	property string url480p
	property string url360p
	property string url240p
	property string ytQual
	////////////////////////////////////////////////////

	property QtObject mainPage

	//property string homePath // Use from C++ QStandardsPath
	//property string videoPath

	header: Kirigami.ApplicationHeader {
		preferredHeight: Kirigami.Units.gridUnit * 2.25
	}

	globalDrawer: GlobalDrawer {}

	contextDrawer: Kirigami.ContextDrawer {
		id: contextDrawer
	}

	// drawer components
	Component {
		id: historyPageComponent
		HistoryPage {}
	}

	Component {
		id: youtubeSearchComponent
		YoutubeSearch {}
	}

	Component {
		id: openDialogComponent
		OpenDialog {}
	}

	Component {
		id: openUrlComponent
		OpenUrl {}
	}
	
	Component {
		id: aboutPageComponent
		AboutPage {}
	}

	// components not needed for the drawer

	Component {
		id: playerPageComponent
		PlayerPage {}
	}
	

	function loadPlayer(title,url) {
		streamTitle = title
		streamUrl = url
		applicationWindow().pageStack.replace(playerPageComponent);
	}

	function showPlayer() {
		applicationWindow().pageStack.replace(playerPageComponent);
	}

	function addHistory(url,title) {
		//console.debug("Adding " + url + " with title " + title);
		historyModel.append({"hurl": url, "htitle": title});
	}

	function add2History(url,title) {
		if (historyModel.containsTitle(title) || historyModel.containsUrl(url)) {
			historyModel.removeUrl(url);
		}
		if (title == "" || title == undefined) title = url
		historyModel.append({"hurl": url, "htitle": title});
	}

	ListModel {
		id: historyModel
		
		function containsTitle(htitle) {
			for (var i=0; i<count; i++) {
				if (get(i).htitle == htitle)  {
					return true;
				}
			}
			return false;
		}
		function containsUrl(hurl) {
			for (var i=0; i<count; i++) {
				if (get(i).hurl == hurl)  {
					return true;
				}
			}
			return false;
		}
		function removeUrl(hurl) {
			for (var i=0; i<count; i++) {
				if (get(i).hurl == hurl)  {
					remove(i)
				}
			}
			return;
		}
	}    

	Component.onCompleted: { 
		// Intitialize DB
		DB.initialize();
		DB.getHistory();
		pageStack.push(openDialogComponent);
	}
}
