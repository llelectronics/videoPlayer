/*
  Copyright (C) 2013 Leszek Lesner.
  Contact: Leszek Lesner <leszek.lesner@web.de>
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
import Sailfish.Media 1.0
//import Sailfish.Gallery 1.0
import "helper"

Page {
    id: page
    allowedOrientations: Orientation.All
    property int videoDuration
    property string streamUrl
    property string title: videoPoster.player.metaData.title ? videoPoster.player.metaData.title : ""
    property string artist: videoPoster.player.metaData.albumArtist ? videoPoster.player.metaData.albumArtist : ""
    property alias onlyMusic: onlyMusic
    property alias videoPoster: videoPoster
    signal updateCover

    Component.onCompleted: {
            // Initialize the database
            DB.initialize();
//            DB.showHistoryLast();
//            DB.getHistory();
        }

    onStreamUrlChanged: {
        //Write into history database
        DB.addHistory(streamUrl);
        if (errorDetail.visible || errorTxt.visible) { errorDetail.visible = false; errorTxt.visible = false }
    }

    PageHeader {
        title: streamUrl
        visible: page.orientation === Orientation.Portrait ? true : false
    }

    function videoPauseTrigger() {
        // this seems not to work somehow
        if (videoPoster.player.playbackState == MediaPlayer.PlayingState) videoPoster.player.pause();
        else if (videoPoster.source.toString().length !== 0) videoPoster.player.play();
        if (videoPoster.controls.opacity === 0.0) videoPoster.toggleControls();

    }

    SilicaFlickable {
        anchors.fill: parent


        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            id: pulley
            MenuItem {
                text: "About "+ appname
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
            }
            MenuItem {
                text: "Search Youtube"
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"), {dataContainer: page});
            }
            MenuItem {
                text: "Open URL"
                onClicked: pageStack.push(Qt.resolvedUrl("OpenURLPage.qml"), {dataContainer: page, streamUrl: streamUrl});
            }
            MenuItem {
                text: "Open File"
                onClicked: pageStack.push(Qt.resolvedUrl("fileman/Main.qml"), {dataContainer: page});
            }
        }

        Image {
            id: onlyMusic
            anchors.centerIn: parent
            source: Qt.resolvedUrl("images/audio.png")
            opacity: 0.0
            Behavior on opacity { FadeAnimation { } }
        }

        ProgressCircle {
            id: progressCircle

            anchors.centerIn: parent
            visible: false

            Timer {
                interval: 32
                repeat: true
                onTriggered: progressCircle.value = (progressCircle.value + 0.005) % 1.0
                running: visible
            }
        }

        Label {
            // TODO: seems only show error number. Maybe disable in the future
            id: errorTxt
            text: ""
            visible: {
                if (text !== "" && page.orientation === Orientation.Portrait ) return true;
                else return false;
            }
            anchors.top: parent.top
            anchors.topMargin: 65
            font.bold: true
        }


        TextArea {
            id: errorDetail
            text: ""
            visible: {
                if (text !== "" && page.orientation === Orientation.Portrait ) return true;
                else return false;
            }
            width: parent.width
            height: parent.height / 3
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: errorTxt.bottom
            anchors.topMargin: 15
            font.bold: false
            color: "white"
        }

        Item {
            id: mediaItem
            property bool active : true
            visible: active

            VideoPoster {
                id: videoPoster
                width: page.orientation === Orientation.Portrait ? Screen.width : Screen.height
                height: page.height

                player: mediaPlayer

                //duration: videoDuration
                active: mediaItem.active
                source: streamUrl
                //onSourceChanged: play();  // autoPlay TODO: add config for it
                //source: "file:///home/nemo/Videos/eva.mp4"
                //source: "http://netrunnerlinux.com/vids/default-panel-script.mkv"
                //source: "http://www.ytapi.com/?vid=lfAixpkzcBQ&format=direct"

                onPlayClicked: toggleControls();

                function toggleControls() {
                    //console.debug("Controls Opacity:" + controls.opacity);
                    if (controls.opacity === 0.0) {
                        //console.debug("Show controls");
                        controls.opacity = 1.0;
                    }
                    else {
                        //console.debug("Hide controls");
                        controls.opacity = 0.0;
                    }
                    page.showNavigationIndicator = !page.showNavigationIndicator
                    pulley.visible = !pulley.visible
                }


                onClicked: {
                    if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                        //console.debug("Mouse values:" + mouse.x + " x " + mouse.y)
                        var middleX = width / 2
                        var middleY = height / 2
                        if ((mouse.x >= middleX - 21 && mouse.x <= middleX + 21) && (mouse.y >= middleY - 21 && mouse.y <= middleY + 21)) {
                            mediaPlayer.pause();
                            if (controls.opacity === 0.0) toggleControls();
                            progressCircle.visible = false;
                        }
                        else {
                            toggleControls();
                        }
                    } else {
                        //mediaPlayer.play()
                        console.debug("clicked something else")
                        toggleControls();
                    }
                }
            }
        }
    }
    children: [

        // Always use a black background
        Rectangle {
            anchors.fill: parent
            color: "black"
            visible: video.visible
        },

        GStreamerVideoOutput {
            id: video

            source: MediaPlayer {
                id: mediaPlayer
                function loadMetaDataPage() {
                    //console.debug("Loading metadata page")
                    pageStack.pushAttached(Qt.resolvedUrl("FileDetails.qml"), {
                                               filename: streamUrl,
                                               title: metaData.title,
                                               artist: metaData.albumArtist,
                                               videocodec: metaData.videoCodec,
                                               resolution: metaData.resolution,
                                               videobitrate: metaData.videoBitRate,
                                               framerate: metaData.videoFrameRate,
                                               audiocodec: metaData.audioCodec,
                                               audiobitrate: metaData.audioBitRate,
                                               samplerate: metaData.sampleRate,
                                               copyright: metaData.copyright,
                                               date: metaData.date,
                                               size: metaData.size
                                           });
                }

                onDurationChanged: {
                    videoPoster.duration = (duration/1000);
                    loadMetaDataPage();
                    if (hasAudio === true && hasVideo === false) onlyMusic.opacity = 1.0
                    else onlyMusic.opacity = 0.0;
                }
                onStatusChanged: {
                    //errorTxt.visible = false     // DEBUG: Always show errors for now
                    //errorDetail.visible = false
                    //console.debug("PlaybackStatus: " + playbackState)
                    if (mediaPlayer.status === MediaPlayer.Loading || mediaPlayer.status === MediaPlayer.Buffering || mediaPlayer.status === MediaPlayer.Stalled) progressCircle.visible = true;
                    else progressCircle.visible = false;
                }
                onError: {
                    errorTxt.text = error;
                    errorDetail.text = errorString;
                }
            }

            visible: mediaPlayer.status >= MediaPlayer.Loaded && mediaPlayer.status <= MediaPlayer.EndOfMedia
            width: parent.width
            height: parent.height
            anchors.centerIn: page

            ScreenBlank {
                suspend: mediaPlayer.playbackState == MediaPlayer.PlayingState
            }
        }
    ]
}


