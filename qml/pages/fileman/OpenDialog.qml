import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.videoplayer.Videoplayer 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    signal openFile(string path);

    property var path
    property var filter

    FolderListModel {
        id: fileModel
        folder: path
        showDirsFirst: true
        showDotAndDotDot: true
        showOnlyReadable: true
        nameFilters: filter
    }

    function getReadableFileSizeString(fileSizeInBytes) {
        var i = -1;
        var byteUnits = [' kB', ' MB', ' GB', ' TB', 'PB', 'EB', 'ZB', 'YB'];
        do {
            fileSizeInBytes = fileSizeInBytes / 1024;
            i++;
        } while (fileSizeInBytes > 1024);

        return Math.max(fileSizeInBytes, 0.1).toFixed(1) + byteUnits[i];
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
            height: fileDetailsLbl.visible ? fileNameLbl.height + fileDetailsLbl.height : Theme.itemSizeSmall

            Item {
                id: dItem
                anchors.fill: parent

                Label {
                    id: fileNameLbl
                    text: fileName + (fileIsDir ? "/" : "")
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    wrapMode: Text.WordWrap
                    width: parent.width - (Theme.paddingMedium * 2)
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    id: fileDetailsLbl
                    anchors.top: fileNameLbl.bottom
                    visible: !fileIsDir
                    text: getReadableFileSizeString(fileSize) + ", " + fileModified
                    color: Theme.secondaryColor
                    truncationMode: TruncationMode.Fade
                    width: parent.width - (Theme.paddingMedium * 2)
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                }
                Component.onCompleted: {
                    if (!fileDetailsLbl.visible) fileNameLbl.anchors.verticalCenter = dItem.verticalCenter
                    else fileNameLbl.anchors.top = dItem.top
                }
            }

            onClicked: {
                if (fileIsDir) {
                    if (fileName === "..") fileModel.folder = fileModel.parentFolder
                    else if (fileName === ".") return
                    else fileModel.folder = filePath
                } else {
                    openFile(filePath)
                }
            }
        }
        VerticalScrollDecorator { flickable: view }
    }
}
