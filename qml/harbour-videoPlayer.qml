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

ApplicationWindow
{
    id: mainWindow

    property Item firstPage
    property bool autoPlay: false
    property alias modelBookmarks: modelBookmarks

    property string version: "0.7"
    property string appname: "LLs Video Player"
    property string appicon: "images/icon.png"

    signal fileRemove(string url)

    function loadUrl(url) {
        // Check if youtube url
        if (YT.checkYoutube(url) === true) {
            YT.getYoutubeTitle(url);
            url = YT.getYoutubeVid(url);
        }
        firstPage.originalUrl = url
        firstPage.streamUrl = url
        firstPage.streamTitle = ""
        if (autoPlay == true) { console.debug("autoPlay = true") ; firstPage.videoPoster.play();}
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
            DB.addBookmark(bookmarkTitle,bookmarkUrl);
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
}


