import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.videoplayer.Videoplayer 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    signal openFile(string path);

    property var editor

    FolderListModel {
        id: fileModel
        folder: "/home/nemo/Videos"
        showDirsFirst: true
        showDotAndDotDot: true
        showOnlyReadable: true
    }

    SilicaListView {
        id: view
        model: fileModel
        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Open file")
        }

        PullDownMenu {
            MenuItem {
                text: "Show Filesystem Root"
                onClicked: fileModel.folder = "/";
            }
            MenuItem {
                text: "Show Home"
                onClicked: fileModel.folder = "/home/nemo";
            }
            MenuItem {
                text: "Show Android SDCard"
                onClicked: fileModel.folder = "/data/sdcard";
            }
            MenuItem {
                text: "Show SDCard"
                onClicked: fileModel.folder = "/media/sdcard";
                //visible: Util.existsPath("/media/sdcard")
                //Component.onCompleted: console.debug("[DirList] SD Card status: " + Util.existsPath("/media/sdcard"))
            }
    //        MenuItem {
    //            text: "Marked Paths"
    //            onClicked: entriesList.showStoredPaths()
    //        }
        }

        delegate: BackgroundItem {
            id: delegate
            width: parent.width

            Column {
                width: parent.width

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    text: fileName + (fileIsDir ? "/" : "")
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                Label {
                    visible: !fileIsDir
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    text: fileSize + ", " + fileModified
                    color: Theme.secondaryColor
                }
            }

            onClicked: {
                if (fileIsDir) {
                    if (fileName === "..") fileModel.folder = fileModel.parentFolder
                    else if (fileName === ".") return
                    else fileModel.folder = filePath
                } else {
                    openFile(filePath)
                    pageStack.pop()
                }
            }
        }
        VerticalScrollDecorator { flickable: view }
    }
}
