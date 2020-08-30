import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property string streamTitle
    property string url720p
    property string url480p
    property string url360p
    property string url240p
    property bool ytDownload: false

    // Private
    property bool _oggLoaded
    property bool _opusLoaded
    property bool _fullHdLoaded

    allowedOrientations: Orientation.All

    Component.onCompleted: {

        _ytdl.getMusicUrls();
        //_ytdl.getDashUrls();
        loading.running = true;

        if (url720p != "none" && url720p != undefined && url720p != "") {
            //console.debug("Added 720p with" + url720p)
            qualList.append({"name": "MP4 720p", "url":url720p, "audioUrl": "", "isDash": "false"})
        }
        if (url480p != "none" && url480p != undefined && url480p != "") {
            //console.debug("Added 480p with " + url480p)
            qualList.append({"name": "WEBM 480p", "url":url480p, "audioUrl": "", "isDash": "false"})
        }
        if (url360p != "none" && url360p != undefined && url360p != "") {
            //console.debug("Added 360p with" + url360p)
            qualList.append({"name": "MP4 360p", "url":url360p, "audioUrl": "", "isDash": "false"})
        }
        if (url240p != "none" && url240p != undefined && url240p != "") {
            //console.debug("Added 240p with" + url240p)
            qualList.append({"name": "FLV 240p", "url":url240p, "audioUrl": "", "isDash": "false"})
        }

    }

    ListModel {
        id: qualList
//        ListElement {
//            name: "test"
//            url: ""
//        }
    }

    SilicaListView {
        id: qualListView
        model: qualList
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Choose Quality")
        }
        delegate: BackgroundItem {
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            width: parent.width - Theme.paddingLarge
            Label {
                text: name
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: {
                if (ytDownload) {
                    var suf
                    if (url != "") {
                        if (name == "MP4 720p") suf = ".mp4"
                        else if (name == "WEBM 480p") suf = ".webm"
                        else if (name == "MP4 360p") suf = ".mp4"
                        else if (name == "FLV 240p") suf = ".flv"
                        else if (name == "vorbis@128k Audio (WEBM)") suf = ".webm"
                        else if (name == "opus@160k Audio (WEBM)") suf = ".webm"
                        pageStack.replace(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": url, "downloadName": streamTitle + suf});
                    }
                }
                else {
                    if (isDash === "true") {
                        firstPage.streamUrl = url
                        firstPage.isDash = true
                        minPlayer.source = audioUrl
                        pageStack.pop();
                    }
                    else if (url != "") {
                        firstPage.streamUrl = url
                        if (name == "MP4 720p") firstPage.ytQual = "720p"
                        else if (name == "FLV 480p") firstPage.ytQual = "480p"
                        else if (name == "MP4 360p") firstPage.ytQual = "360p"
                        else if (name == "FLV 240p") firstPage.ytQual = "240p"
                        firstPage.streamTitle = streamTitle
                        pageStack.pop();
                    }
                }
            }
        }
    }

    BusyIndicator {
        id: loading
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        size: BusyIndicatorSize.Medium
        running: false
        visible: running
    }

    Connections {
        target: _ytdl
        onOggAudioChanged: {
            if (_ytdl.getOggAudioUrl() !== "") {  // Don't load empty stuff
                qualList.append({"name": "vorbis@128k Audio (WEBM)", "url": _ytdl.getOggAudioUrl(), "audioUrl": "", "isDash": "false"})
                _oggLoaded = true
                if (_opusLoaded) loading.running = false
            }
        }
        onOpusAudioChanged: {
            if (_ytdl.getOpusAudioUrl() !== "") {  // Don't load empty stuff
                qualList.append({"name": "opus@160k Audio (WEBM)", "url": _ytdl.getOpusAudioUrl(), "audioUrl": "", "isDash": "false"})
                _opusLoaded = true
                if (_oggLoaded) loading.running = false
            }
        }
        onFullHdChanged: {
            if (_ytdl.getFullHdAudioUrl() !== "" && _ytdl.getFullHdVideoUrl() !== "") {
                qualList.append({"name": "1080p FullHD (MP4)", "url": _ytdl.getFullHdVideoUrl(), "audioUrl": _ytdl.getFullHdAudioUrl(), "isDash": "true"})
                _fullHdLoaded = true
                if (_fullHdLoaded) loading.running = false
            }
        }
    }
}

