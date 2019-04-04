import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6

MediaPlayer {
    id: mediaPlayer

    property QtObject dataContainer
    property string streamTitle
    property string streamUrl
    property bool isPlaylist
    property bool isNewSource: true
    property bool isLiveStream: false
    property bool isPlaying: playbackState === MediaPlayer.PlayingState ? true : false
    property bool isMinMode

    function loadPlaylistPage() {
        var playlistPage = pageStack.pushAttached(Qt.resolvedUrl("../PlaylistPage.qml"), { "dataContainer" : dataContainer, "modelPlaylist" : mainWindow.modelPlaylist, "isPlayer" : true});

    }

    function loadMetaDataPage() {
        //console.debug("Loading metadata page")
        var mDataTitle;
        //console.debug(metaData.title)
        if (streamTitle != "") mDataTitle = streamTitle
        else mDataTitle = mainWindow.findBaseName(streamUrl)
        //console.debug("[mDataTitle]: " + mDataTitle)
        if (typeof(dPage) !== "undefined") {
            dPage = pageStack.pushAttached(Qt.resolvedUrl("../FileDetails.qml"), {
                                               filename: streamUrl,
                                               title: mDataTitle,
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
                                               size: mainWindow.humanSize(_fm.getSize(streamUrl)) //metaData.size
                                           });
        }
    }

    onDurationChanged: {
        if (!isMinMode) {
            //console.debug("Duration(msec): " + duration);
            videoPoster.duration = (duration/1000);
            if (hasAudio === true && hasVideo === false) onlyMusic.opacity = 1.0
            else onlyMusic.opacity = 0.0;
        }
    }
    onStatusChanged: {
        if (!isMinMode) {
            //errorTxt.visible = false     // DEBUG: Always show errors for now
            //errorDetail.visible = false
            //console.debug("[videoPlayer.qml]: mediaPlayer.status: " + mediaPlayer.status)
            if (mediaPlayer.status === MediaPlayer.Loading || mediaPlayer.status === MediaPlayer.Buffering || mediaPlayer.status === MediaPlayer.Stalled) progressCircle.visible = true;
            else if (mediaPlayer.status === MediaPlayer.EndOfMedia) {
                videoPoster.showControls();
                if (isPlaylist && mainWindow.modelPlaylist.isNext()) {
                    videoPoster.next();
                }
            }
            else  {
                progressCircle.visible = false;
                if (!isPlaylist) loadMetaDataPage();
                else loadPlaylistPage();
            }
            if (metaData.title) {
                //console.debug("MetaData.title = " + metaData.title)
                if (dPage) dPage.title = metaData.title
                mprisPlayer.title = metaData.title
            }
        }
    }

    onError: {
        if (!isMinMode) {
            // Just a little help
            //            MediaPlayer.NoError - there is no current error.
            //            MediaPlayer.ResourceError - the video cannot be played due to a problem allocating resources.
            //            MediaPlayer.FormatError - the video format is not supported.
            //            MediaPlayer.NetworkError - the video cannot be played due to network issues.
            //            MediaPlayer.AccessDenied - the video cannot be played due to insufficient permissions.
            //            MediaPlayer.ServiceMissing - the video cannot be played because the media service could not be instantiated.
            if (error == MediaPlayer.ResourceError) errorTxt.text = "Ressource Error";
            else if (error == MediaPlayer.FormatError) errorTxt.text = "Format Error";
            else if (error == MediaPlayer.NetworkError) errorTxt.text = "Network Error";
            else if (error == MediaPlayer.AccessDenied) errorTxt.text = "Access Denied Error";
            else if (error == MediaPlayer.ServiceMissing) errorTxt.text = "Media Service Missing Error";
            //errorTxt.text = error;
            // Prepare user friendly advise on error
            errorDetail.text = errorString;
            if (error == MediaPlayer.ResourceError) errorDetail.text += qsTr("\nThe video cannot be played due to a problem allocating resources.\n\
            On Youtube Videos please make sure to be logged in. Some videos might be geoblocked or require you to be logged into youtube.")
            else if (error == MediaPlayer.FormatError) errorDetail.text += qsTr("\nThe audio and or video format is not supported.")
            else if (error == MediaPlayer.NetworkError) errorDetail.text += qsTr("\nThe video cannot be played due to network issues.")
            else if (error == MediaPlayer.AccessDenied) errorDetail.text += qsTr("\nThe video cannot be played due to insufficient permissions.")
            else if (error == MediaPlayer.ServiceMissing) errorDetail.text += qsTr("\nThe video cannot be played because the media service could not be instantiated.")
            errorBox.visible = true;
            /* Avoid MediaPlayer undefined behavior */
            stop();
        }
    }
    onBufferProgressChanged: {
        if (!isMinMode) {
            if (!isLiveStream) {
                if (bufferProgress == 1.0 && isNewSource) {
                    isNewSource = false
                    play()
                } else if(isNewSource) pause()
            }
            else {
                if (bufferProgress == 0.7 && isNewSource) { // 7% filling for live streams
                    isNewSource = false
                    play()
                } else if(isNewSource) pause()
            }
        }
    }
}

