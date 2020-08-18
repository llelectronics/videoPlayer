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

   property string duration
   property string thumbnail
   property alias title: fullTitle.text
   property alias channelName: channelName.text
   property string uploadDate
   property string channelUrl
   property string videoUrl
   property string videoId
   property string url720p
   property string url480p
   property string url360p
   property string url240p

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
       width: parent.width
       height: dataContainer.height * 0.28 // 28 %
       source: thumbnail
       MouseArea {
           anchors.fill: parent
           onPressed: parent.highlighted = true
           onReleased: parent.highlighted = false
           onClicked: {
               dataContainer.isYtUrl = false;
               dataContainer.streamUrl = videoUrl;
               dataContainer.streamTitle = title
               dataContainer.originalUrl = "https://youtube.com/watch?v=" + videoId
               dataContainer.isPlaylist = false;
               dataContainer.isLiveStream = false;
               dataContainer.loadPlayer();
           }
       }
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
   TextArea {
       id: fullTitle
       anchors.top: thumb.bottom
       anchors.left: thumb.left
       anchors.leftMargin: Theme.paddingLarge
       anchors.right: thumb.right
       anchors.rightMargin: Theme.paddingLarge
       font.bold: true
       width: parent.width
       //height: font.pixelSize * 2
       wrapMode: TextEdit.WordWrap
       readOnly: true
       background: null
   }
   Label {
       id: channelName
       anchors.top: fullTitle.bottom
       anchors.topMargin: Theme.paddingSmall / 2
       anchors.left: fullTitle.left
       font.pixelSize: Theme.fontSizeExtraSmall
   }
   Label {
       id: vDate
       anchors.right: parent.right
       anchors.rightMargin: Theme.paddingMedium
       anchors.top: fullTitle.bottom
       anchors.topMargin: Theme.paddingSmall / 2
       font.pixelSize: Theme.fontSizeExtraSmall
       truncationMode: TruncationMode.Fade
   }

}
