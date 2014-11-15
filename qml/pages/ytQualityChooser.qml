import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property string streamTitle
    property string url720p
    property string url480p
    property string url360p
    property string url240p

    allowedOrientations: Orientation.All

    Component.onCompleted: {

        if (url720p != "none" && url720p != undefined && url720p != "") {
            console.debug("Added 720p with" + url720p)
            qualList.append({"name": "MP4 720p", "url":url720p})
        }
        if (url480p != "none" && url480p != undefined && url480p != "") {
            console.debug("Added 480p with " + url480p)
            qualList.append({"name": "FLV 480p", "url":url480p})
        }
        if (url360p != "none" && url360p != undefined && url360p != "") {
            console.debug("Added 360p with" + url360p)
            qualList.append({"name": "MP4 360p", "url":url360p})
        }
        if (url240p != "none" && url240p != undefined && url240p != "") {
            console.debug("Added 240p with" + url240p)
            qualList.append({"name": "FLV 240p", "url":url240p})
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
            title: "Choose Quality"
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
            onClicked: pageStack.replace(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": url, "downloadName": streamTitle});
        }
    }
}

