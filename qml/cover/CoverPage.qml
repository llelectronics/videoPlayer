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
import QtMultimedia 5.0
import "../pages"

CoverBackground {

    Label {
        id: label
        anchors.centerIn: parent
        text: {
            if (firstPage.title.toString().length !== 0 && firstPage.artist.toString().length !== 0) return firstPage.artist + "\n-\n" + firstPage.title
            else if (firstPage.title.toString().length !== 0) return firstPage.title
            else if (firstPage.streamUrl.toString().length !== 0) return firstPage.streamUrl
            else return "LLs Video Player"
        }
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideLeft
    }

    Image {
        id: img
        source: {
            if (firstPage.onlyMusic.opacity === 1.0) return "../pages/images/audio.png"
            else return "../pages/images/icon.png"
        }
        anchors.bottom: label.top
        anchors.bottomMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        width: 86 // fixed icon size
        height: 86
    }

    Item {
        anchors.top: label.bottom
        anchors.topMargin: 15
        x : (parent.width / 2) - ((curPos.width/2) + (dur.width/2))


        Label {
            id: dur
            text: firstPage.videoDuration
            anchors.left: curPos.right
            color: Theme.highlightColor
        }
        Label {
            id: curPos
            text: firstPage.videoPosition + " / "
            color: Theme.highlightColor
        }
    }

    CoverActionList {
        id: coverAction

//        CoverAction {
//            iconSource: "image://theme/icon-cover-next"
//        }

        CoverAction {
            iconSource: {
                if (firstPage.videoPoster.player.playbackState === MediaPlayer.PlayingState) return "image://theme/icon-cover-pause"
                else return "image://theme/icon-cover-play"
            }
            onTriggered: {
                //console.debug("Pause triggered");
                firstPage.videoPauseTrigger();
            }
        }
    }
}


