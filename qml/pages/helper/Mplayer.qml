import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6

MediaPlayer {
    id: mediaPlayer

    property QtObject dataContainer
    property string streamTitle
    property string streamUrl
    property bool isPlaylist: false
    property bool isNewSource: true
    property bool isLiveStream: false
    property bool isPlaying: playbackState === MediaPlayer.PlayingState ? true : false
    property bool isMinMode

    function loadPlaylistPage() {
        var playlistPage = pageStack.pushAttached(Qt.resolvedUrl("../PlaylistPage.qml"), { "dataContainer" : dataContainer, "modelPlaylist" : mainWindow.modelPlaylist, "isPlayer" : true});

    }

    function loadMetaDataPage(inBackground) {
        //console.debug("Loading metadata page")
        var mDataTitle;
        //console.debug(metaData.title)
        if (streamTitle != "") mDataTitle = streamTitle
        else mDataTitle = mainWindow.findBaseName(streamUrl)
        //console.debug("[mDataTitle]: " + mDataTitle)
        if (typeof(dPage) !== "undefined") {
            if (inBackground === "inBackground") {
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
            else {
                dPage = pageStack.push(Qt.resolvedUrl("../FileDetails.qml"), {
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
    }
//    onBufferProgressChanged: {
//        if (!isLiveStream) {
//            if (bufferProgress == 1.0 && isNewSource) {
//                isNewSource = false
//                play()
//            } else if(isNewSource) pause()
//        }
//        else {
//            if (bufferProgress == 0.7 && isNewSource) { // 7% filling for live streams
//                isNewSource = false
//                play()
//            } else if(isNewSource) pause()
//        }
//        if (bufferProgress < 0.05) pause()
//        if (bufferProgress == 1.0 && !isNewSource) play()
//    }
}

