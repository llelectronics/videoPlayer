/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Window 2.1
import "pages"
import "pages/helper/yt.js" as YT
import "pages/helper/db.js" as DB
import "pages/helper/m3u.js" as M3U
import harbour.videoplayer.Videoplayer 1.0
import "pages/helper"
import QtMultimedia 5.0
import org.nemomobile.mpris 1.0

ApplicationWindow
{
    id: mainWindow

    property Item firstPage
    property bool autoPlay: false
    property alias modelBookmarks: modelBookmarks
    property alias modelPlaylist: modelPlaylist
    property alias playlist: playlist
    property int curPlaylistIndex: -1
    property alias busy: busy
    property alias infoBanner: infoBanner
    property alias downloadModel: downloadModel
    property alias errTxt: errTxt
    property bool clearWebViewOnExit: false
    property bool isLightTheme: {
        if (Theme.colorScheme === Theme.LightOnDark) return false
        else return true
    }
    property alias mprisPlayer: mprisPlayer
    property bool isYtSearchRunning: false
    property bool isYtSearchAborted: false

    property string version: "3.0"
    property string appname: "LLs Video Player"
    property string appicon: "images/icon.png"

    allowedOrientations: defaultAllowedOrientations

    signal fileRemove(string url)

    function isUrl(url) {
        var pattern = new RegExp(/^(?:(?:https?|ftp):\/\/)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?$/i);
        if(!pattern.test(url)) {
            //console.debug("Not a valid URL.");
            return false;
        } else {
            return true;
        }
    }

    function contains(txt,search) {
        if (txt.indexOf(search) !== -1) return true
        else return false
    }

    function endsWith(str, suffix) {
        return str.indexOf(suffix, str.length - suffix.length) !== -1;
    }

    function readM3uFile(file)
    {
        var allText
        var rawFile = new XMLHttpRequest();
        rawFile.open("GET", file, false);
        rawFile.onreadystatechange = function ()
        {
            if(rawFile.readyState === 4)
            {
                if(rawFile.status === 200 || rawFile.status == 0)
                {
                    allText = rawFile.responseText;
                    var m3uPlaylist = M3U.parse(allText);
                    // Make sure Playlist is clear
                    modelPlaylist.clear();
                    for (var i=0; i< m3uPlaylist.tracks.length; i++) {
                        //console.debug(m3uPlaylist.tracks[i].title + " " + m3uPlaylist.tracks[i].file);
                        if (m3uPlaylist.tracks[i].title && m3uPlaylist.tracks[i].title !== "")
                            modelPlaylist.addTrack(m3uPlaylist.tracks[i].file,m3uPlaylist.tracks[i].title);
                        else
                            modelPlaylist.addTrack(m3uPlaylist.tracks[i].file,"");
                    }
                }
            }
        }
        rawFile.send(null);
    }

    function loadUrl(url) {
        if (autoPlay == true) {
            console.debug("autoPlay = true") ;
            firstPage.autoplay = true;
        }
        // Check if youtube url
        if (YT.checkYoutube(url) === true) {
            YT.getYoutubeTitle(url);
            firstPage.originalUrl = url
            firstPage.streamUrl = url
            firstPage.loadPlayer();
            firstPage.isYtUrl = true;
            //url = YT.getYoutubeVid(url);
        }
        else if (isUrl(url)) {
            // Call C++ side here to grab url
            _ytdl.setUrl(url);
            _ytdl.getStreamUrl();
            _ytdl.getStreamTitle();
            firstPage.isYtUrl = false;
            busy.visible = true;
            busy.running = true;
        }
        else {
            firstPage.originalUrl = url
            firstPage.streamUrl = url
            firstPage.streamTitle = ""
            firstPage.isYtUrl = false;
            firstPage.loadPlayer();
        }
    }

    function findBaseName(url) {
        var fileName = url.substring(url.lastIndexOf('/') + 1);
        var dot = fileName.lastIndexOf('.');
        return dot === -1 ? fileName : fileName.substring(0, dot);
    }

    function humanSize(bytes) {
        var precision = 2;
        var kilobyte = 1024;
        var megabyte = kilobyte * 1024;
        var gigabyte = megabyte * 1024;
        var terabyte = gigabyte * 1024;

        if ((bytes >= 0) && (bytes < kilobyte)) {
            return bytes + ' B';

        } else if ((bytes >= kilobyte) && (bytes < megabyte)) {
            return (bytes / kilobyte).toFixed(precision) + ' KB';

        } else if ((bytes >= megabyte) && (bytes < gigabyte)) {
            return (bytes / megabyte).toFixed(precision) + ' MB';

        } else if ((bytes >= gigabyte) && (bytes < terabyte)) {
            return (bytes / gigabyte).toFixed(precision) + ' GB';

        } else if (bytes >= terabyte) {
            return (bytes / terabyte).toFixed(precision) + ' TB';

        } else {
            return bytes + ' B';
        }
    }

    function _clearHistory() {
        DB.clearTable("history");
        DB.clearTable("searchHistory");
        mainWindow.firstPage.historyModel.clear();
        mainWindow.firstPage.searchHistoryModel.clear();
    }

    initialPage: Component {
        FirstPage {
            id: firstPage

            Component.onCompleted: { mainWindow.firstPage = firstPage; DB.getSettings(); }
            onRemoveFile: {
                console.debug("Request removal of" + url);
                fileRemove(url);
            }
        }
    }
    //cover: Qt.resolvedUrl("cover/CoverPage.qml")
    cover: {
        if (firstPage.liveView) return undefined
        else return Qt.resolvedUrl("cover/CoverPage.qml")

    }

    onApplicationActiveChanged: {
        if (pageStack.currentPage.objectName === "videoPlayerPage") {
            if (!mainWindow.applicationActive) {
                pageStack.currentPage.videoPoster.hideControls();
                pageStack.currentPage.showTimeAndTitle.count = 0
                pageStack.currentPage.showTimeAndTitle.start();
            }
            else if (mainWindow.applicationActive === true) {
                pageStack.currentPage.showTimeAndTitle.count = 5
                if (pageStack.currentPage.videoPoster.opacity === 0) pageStack.currentPage.videoPoster.toggleControls();
            }
        }
        else if (typeof pageStack.currentPage.workaroundRefresh === 'function') {
            pageStack.currentPage.workaroundRefresh();
        }
    }

    ListModel {
        id: downloadModel

        // Example data
        //        ListElement {
        //            name: "foobar"
        //            url: "http://download/foo.bar"
        //            downLocation: "home/nemo/Downloads/foo.bar"
        //        }
    }

    ListModel {
        id:modelBookmarks

        Component.onCompleted: {
            DB.getBookmarks();
        }

        function contains(bookmarkUrl) {
            var suffix = "/";
            var str = bookmarkUrl.toString();
            for (var i=0; i<count; i++) {
                if (get(i).url === str)  {
                    return true;
                }
                // check if url endswith '/' and return true if url-'/' = models url
                else if (str.indexOf(suffix, str.length - suffix.length) !== -1) {
                    if (get(i).url === str.substring(0, str.length-1)) return true;
                }
            }
            return false;
        }

        function editBookmark(oldTitle, bookmarkTitle, bookmarkUrl, liveStream) {
            for (var i=0; i<count; i++) {
                if (get(i).title === oldTitle) set(i,{"title":bookmarkTitle, "url":bookmarkUrl, "liveStream": liveStream});
            }
            DB.editBookmark(oldTitle,bookmarkTitle,bookmarkUrl, liveStream);
        }

        function removeBookmark(bookmarkUrl) {
            for (var i=0; i<count; i++) {
                if (get(i).url === bookmarkUrl) remove(i);
            }
            DB.removeBookmark(bookmarkUrl);
        }

        function addBookmark(bookmarkUrl, bookmarkTitle, liveStream) {
            append({"title":bookmarkTitle, "url":bookmarkUrl, "liveStream": liveStream});
            DB.addBookmark(bookmarkTitle,bookmarkUrl,liveStream);
        }
    }

    ListModel {
        id: modelPlaylist
        property int current: 0
        property bool active: false
        property bool isNew: false
        property string name

        function isNext() {
            if (current != count-1) return true
            else return false
        }

        function isPrev() {
            if (current != 0) return true
            else return false
        }

        function next() {
            if (isNext()) {
                var nextUrl = get(current+1).url
                var nextTitle = get(current+1).title
                current = current + 1
                return [ nextUrl, nextTitle ]
            }
        }

        function prev() {
            if (isPrev()) {
                var prevUrl = get(current-1).url
                var prevTitle = get(current-1).title
                current = current - 1
                return [ prevUrl, prevTitle ]
            }
        }

        function removeTrack(url) {
            for (var i=0; i<count; i++) {
                if (get(i).url === url) {
                    remove(i);
                    playlist.remove(i);
                }
            }
        }

        function addTrackToTop(url, title) {
            if (title !== "")
                insert(0, {"title" : title, "url" : url});
            else
                insert(0, {"title" : findBaseName(url), "url" : url});
            playlist.insert(0,url);
        }

        function addTrack(url, title) {
            if (title !== "")
                append({"title" : title, "url" : url});
            else
                append({"title" : findBaseName(url), "url" : url});
            playlist.add(url);
        }

        function getPosition(str) {
            for (var i=0; i<count; i++) {
                if (get(i).url === str)  {
                    return i;
                }
            }
            return 0; // Fallback
        }
    }

    Playlist {
        id: playlist
        //        pllist: "/home/nemo/Music/playlists/MGS.pls"

        onPllistChanged: {
            //console.debug("[harbour-videoPlayer.qml] Playlist Example entry 0 url: " + playlist.get(playlist.count()-1));
            modelPlaylist.clear();
            if (!modelPlaylist.isNew) {
                for (var i = 0; i < count(); i++) {
                    modelPlaylist.append({"title" : findBaseName(playlist.get(i)), "url" : playlist.get(i)});
                }
            }
            modelPlaylist.active = true
        }
    }

    Mplayer {
        id: minPlayer
        isMinMode: true
        audioRole: MediaPlayer.MusicRole
        onStatusChanged: {
            if (minPlayer.status === MediaPlayer.EndOfMedia) {
                if (isPlaylist && modelPlaylist.isNext()) {
                    minPlayer.stop()
                    minPlayer.source = modelPlaylist.next()
                    minPlayer.play()
                }
            }
        }
        onSourceChanged: {
            if (isPlaylist) curPlaylistIndex = modelPlaylist.getPosition(source)
        }
        onPlaybackStateChanged: {
            if (playbackState == MediaPlayer.PlayingState) mprisPlayer.playbackStatus = Mpris.Playing
            else mprisPlayer.playbackStatus = Mpris.Paused
        }
    }

    Component {
        id: minPlayerComponent
        MinPlayerPanel {
            id: minPlayerPanel
        }
    }
    Loader {
        id: minPlayerLoader
    }

    MprisConnector {
        id: mprisPlayer
    }

    InfoBanner {
        id: infoBanner
        z:1
    }

    Rectangle {
        id: bgOverlay
        color: Theme.overlayBackgroundColor
        opacity: 0.60
        anchors.fill: parent
        visible: {
            if (busy.running) return true;
            else if (errTxt.visible) return true;
            else return false;
        }
    }

    Item {
        id: bgItem
        rotation: mainWindow._rotatingItem.rotation
        anchors.centerIn: parent
        width: pageStack.verticalOrientation ? parent.width : parent.height
        height: pageStack.verticalOrientation ? parent.height : parent.width

        BusyIndicator {
            id: busy
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            running: false
            visible: false
        }
        Label {
            anchors.top: busy.bottom
            anchors.topMargin: Theme.paddingLarge * 2
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Loading Youtube results...")
            visible: isYtSearchRunning && busy.visible
        }
        MouseArea {
            anchors.fill: parent
            enabled: busy.visible
        }
        Button {
            id: abortBtn
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            visible: isYtSearchRunning && busy.visible
            text: qsTr("Abort")
            onClicked: {
                busy.visible = false;
                busy.running = false;
                isYtSearchRunning = false;
                isYtSearchAborted = true;
                _ytdl.killYtSearch();
            }
        }
        TextArea {
            id: errTxt
            anchors.top: parent.top
            height: parent.height - (dismissBtn.height + Theme.paddingLarge)
            width: parent.width
            font.pointSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            visible: false
            background: null
            wrapMode: TextEdit.WordWrap
            readOnly: true
            z: dismissBtn.z + 1
        }
        Button {
            id: dismissBtn
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            visible: errTxt.visible
            text: qsTr("Dismiss")
            onClicked: {
                if (errTxt.visible) errTxt.visible = false;
            }
        }
    }

    // What a hack to create a on Closing behavior
    Window {
        visible: false
        onClosing: {
            //console.debug(_fm.data_dir())
            if (clearWebViewOnExit) {
                //console.debug("ClearWebViewOnExit is set to true so remove " + _fm.data_dir() + "/.QtWebKit");
                _fm.removeDir(_fm.data_dir() + "/.QtWebKit");
                _clearHistory();
            }
        }
    }
}


