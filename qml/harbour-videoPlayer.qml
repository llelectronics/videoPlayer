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
import "pages"
import "pages/helper/yt.js" as YT
import "pages/helper/db.js" as DB
import harbour.videoplayer.Videoplayer 1.0

ApplicationWindow
{
    id: mainWindow

    property Item firstPage
    property bool autoPlay: false
    property alias modelBookmarks: modelBookmarks
    property alias modelPlaylist: modelPlaylist
    property alias playlist: playlist
    property alias busy: busy
    property alias infoBanner: infoBanner
    property alias downloadModel: downloadModel

    property string version: "1.6"
    property string appname: "LLs Video Player"
    property string appicon: "images/icon.png"

    allowedOrientations: defaultAllowedOrientations

    signal fileRemove(string url)

    function isUrl(url) {
        var pattern = new RegExp(/^(([\w]+:)?\/\/)?(([\d\w]|%[a-fA-f\d]{2,2})+(:([\d\w]|%[a-fA-f\d]{2,2})+)?@)?([\d\w][-\d\w]{0,253}[\d\w]\.)+[\w]{2,4}(:[\d]+)?(\/([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)*(\?(&?([-+_~.\d\w]|%[a-fA-f\d]{2,2})=?)*)?(#([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)?$/);
        if(!pattern.test(url)) {
            //console.debug("Not a valid URL.");
            return false;
        } else {
            return true;
        }
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
            //url = YT.getYoutubeVid(url);
        }
        else if (isUrl(url)) {
            // Call C++ side here to grab url
            _ytdl.setUrl(url);
            _ytdl.getStreamUrl();
            _ytdl.getStreamTitle();
            busy.visible = true;
            busy.running = true;
        }
        else {
            firstPage.originalUrl = url
            firstPage.streamUrl = url
            firstPage.streamTitle = ""
            firstPage.loadPlayer();
        }
    }

    function findBaseName(url) {
        var fileName = url.substring(url.lastIndexOf('/') + 1);
        var dot = fileName.lastIndexOf('.');
        return dot == -1 ? fileName : fileName.substring(0, dot);
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
                if (pageStack.currentPage.videoPoster.opacity == 0) pageStack.currentPage.videoPoster.toggleControls();
            }
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
                if (get(i).url == str)  {
                    return true;
                }
                // check if url endswith '/' and return true if url-'/' = models url
                else if (str.indexOf(suffix, str.length - suffix.length) !== -1) {
                    if (get(i).url == str.substring(0, str.length-1)) return true;
                }
            }
            return false;
        }

        function editBookmark(oldTitle, bookmarkTitle, bookmarkUrl) {
            for (var i=0; i<count; i++) {
                if (get(i).title === oldTitle) set(i,{"title":bookmarkTitle, "url":bookmarkUrl});
            }
            DB.editBookmark(oldTitle,bookmarkTitle,bookmarkUrl);
        }

        function removeBookmark(bookmarkUrl) {
            for (var i=0; i<count; i++) {
                if (get(i).url === bookmarkUrl) remove(i);
            }
            DB.removeBookmark(bookmarkUrl);
        }

        function addBookmark(bookmarkUrl, bookmarkTitle) {
            append({"title":bookmarkTitle, "url":bookmarkUrl});
            DB.addBookmark(bookmarkTitle,bookmarkUrl);
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
                current = current + 1
                return nextUrl
            }
        }

        function prev() {
            if (isPrev()) {
                var prevUrl = get(current-1).url
                current = current - 1
                return prevUrl
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

        function addTrack(url) {
            append({"title" : findBaseName(url), "url" : url});
            playlist.add(url);
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

    InfoBanner {
        id: infoBanner
        z:1
    }

    BusyIndicator {
        id: busy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: false
        visible: false
    }
}


