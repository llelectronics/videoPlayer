import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: ytSearchResultItem

    // Thumbnail + Duration
    // Channel Logo // Title (2 lines)
    // Channelname - views - date of upload

    width: parent.width
    height: childrenRect.height + Theme.paddingLarge
    color: "transparent"

    signal longPressed

    property string duration
    property string thumbnail
    property alias title: fullTitle.text
    property alias channelName: channelName.text
    property string channelId
    property string uploadDate
    property string channelUrl
    property string videoUrl
    property string videoId
    property string url720p
    property string url480p
    property string url360p
    property string url240p

    property int _defaultHeight: _isLandscape? thumb.height + Theme.paddingLarge : thumb.height + fullTitle.height + channelName.height + Theme.paddingLarge

    onUploadDateChanged: {
        var locale = Qt.locale()
        var year        = uploadDate.substring(0,4);
        var month       = uploadDate.substring(4,6);
        var day         = uploadDate.substring(6,8);
        var date        = new Date(year, month-1, day);
        vDate.text = date.toLocaleDateString(locale, Locale.ShortFormat)
    }

    onDurationChanged: {
        var durDate = new Date(duration * 1000)
        if (durDate.toISOString().substr(11, 2) != "00")
            dur.text = durDate.toISOString().substr(11, 8)
        else
            dur.text = durDate.toISOString().substr(14, 5)
    }

    HighlightImage {
        id: thumb
        width: _isLandscape ? height * 1.337 : parent.width
        height: ytSearchResultsPage.height * 0.28 // 28 %
        source: thumbnail
    }
    Rectangle {
        id: durRec
        anchors.right: thumb.right
        anchors.bottom: thumb.bottom
        width: dur.width
        height: dur.height
        color: "black"
        opacity: 0.8
    }
    Label {
        id: dur
        anchors.centerIn: durRec
        color: "white"
    }
    // There seems to be no way to retrieve the Channel Logo without using the API which requires a key
    //   Icon {
    //       source: "http://i4.ytimg.com/i/UHW94eEFW7hkUMVaZz4eDg/1.jpg"
    //       width: Theme.iconSizeMedium
    //       height: width
    //       anchors.left: Theme.paddingMedium
    //       anchors.top: fullTitle.verticalCenter
    //       MouseArea {
    //           anchors.fill: parent
    //           onClicked: Qt.openUrlExternally(channelUrl)
    //       }
    //   }
    TextArea {
        id: fullTitle
        anchors.top: _isLandscape ?  parent.top : thumb.bottom
        anchors.left: _isLandscape ? thumb.right : thumb.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: _isLandscape ? parent.right : thumb.right
        anchors.rightMargin: Theme.paddingLarge
        font.bold: true
        width: parent.width
        //height: font.pixelSize * 2
        wrapMode: TextEdit.WordWrap
        readOnly: true
        background: null
    }

    MouseArea {
        property bool down: pressed && containsMouse
        property color highlightedColor: Theme.rgba(palette.highlightBackgroundColor, Theme.highlightBackgroundOpacity)

        width: parent.width
        height: _isLandscape ? thumb.height : thumb.height + fullTitle.height + channelName.height
        onDownChanged: down ? ytSearchResultItem.color = highlightedColor : "transparent"
        onReleased: ytSearchResultItem.color = "transparent"
        onCanceled: ytSearchResultItem.color = "transparent"
        onClicked: {
            console.debug("url720p = " + url720p)
            console.debug("url360p = " + url360p)
            console.debug("url240p = " + url240p)
            dataContainer.url720p = url720p
            dataContainer.url360p = url360p
            dataContainer.url240p = url240p
            if (url720p != "none" && url720p != "" && dataContainer.ytQualWanted == "720p") {
                dataContainer.streamUrl = url720p
                dataContainer.ytQual = "720p"
            }
            if (url360p != "none" && url360p != "" && dataContainer.ytQualWanted == "360p") {
                dataContainer.streamUrl = url360p
                dataContainer.ytQual = "360p"
            }
            if (url240p != "none" && url240p != "" && dataContainer.ytQualWanted == "240p") {
                dataContainer.streamUrl = url240p
                dataContainer.ytQual = "240p"
            }
            dataContainer.streamTitle = title
            dataContainer.originalUrl = "https://youtube.com/watch?v=" + videoId
            dataContainer.isPlaylist = true;
            dataContainer.isLiveStream = false;
            dataContainer.isYtUrl = true;
            dataContainer.ytdlStream = true;
            mainWindow.modelPlaylist.addTrackToTop(url360p,title);
            dataContainer.loadPlayer();
        }
        onPressAndHold: longPressed()
    }

    Label {
        id: channelName
        anchors.top: fullTitle.bottom
        anchors.topMargin: Theme.paddingSmall / 2
        anchors.left: fullTitle.left
        anchors.leftMargin: Theme.paddingLarge
        font.pixelSize: Theme.fontSizeExtraSmall
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.openUrlExternally(channelUrl)
        }
    }
    Label {
        id: vDate
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.top: fullTitle.bottom
        anchors.topMargin: Theme.paddingSmall / 2
        font.pixelSize: Theme.fontSizeExtraSmall
        truncationMode: TruncationMode.Fade
    }

}
