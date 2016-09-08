import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.videoplayer.Videoplayer 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property bool multiSelect: onlyFolders ? true : false
    property bool selectMode: false
    property bool onlyFolders: false
    property string path
    property variant filter: [ "*" ]
    property string title

    property QtObject dataContainer

    signal fileOpen(string path);

    onPathChanged: {
        openFile(path);
    }

    function openFile(path) {
        if (_fm.isFile(path)) {

            fileOpen(path)
        }
    }

    FolderListModel {
        id: fileModel
        folder: path ? path: _fm.getHome()
        showDirsFirst: true
        showDotAndDotDot: true
        showOnlyReadable: true
        nameFilters: filter
    }

    function humanSize(bytes) {
        var precision = 2;
        var kilobyte = 1024;
        var megabyte = kilobyte * 1024;
        var gigabyte = megabyte * 1024;
        var terabyte = gigabyte * 1024;

        if ((bytes >= 0) && (bytes < kilobyte)) {
            return bytes + ' B';

        } else if ((bytes >= kilobyte) && (bytes < megabyte)) {
            return (bytes / kilobyte).toFixed(precision) + ' KB';

        } else if ((bytes >= megabyte) && (bytes < gigabyte)) {
            return (bytes / megabyte).toFixed(precision) + ' MB';

        } else if ((bytes >= gigabyte) && (bytes < terabyte)) {
            return (bytes / gigabyte).toFixed(precision) + ' GB';

        } else if (bytes >= terabyte) {
            return (bytes / terabyte).toFixed(precision) + ' TB';

        } else {
            return bytes + ' B';
        }
    }

    function findBaseName(url) {
        var fileName = url.substring(url.lastIndexOf('/') + 1);
        return fileName;
    }

    SilicaListView {
        id: view
        model: fileModel
        anchors.fill: parent

        header: PageHeader {
            title: if (page.title != "") return page.title 
            else return findBaseName((fileModel.folder).toString())
        }

        PullDownMenu {
            MenuItem {
                text: "Show Filesystem Root"
                onClicked: fileModel.folder = _fm.getRoot();
            }
            MenuItem {
                text: "Show Home"
                onClicked: fileModel.folder = _fm.getHome();
            }
            MenuItem {
                text: "Show Android SDCard"
                onClicked: fileModel.folder = _fm.getRoot() + "/data/sdcard";
            }
            MenuItem {
                text: "Show SDCard"
                onClicked: fileModel.folder = _fm.getRoot() + "/media/sdcard";
            }
        }

        delegate: BackgroundItem {
            id: bgdelegate
            width: parent.width
            height: menuOpen ? contextMenu.height + delegate.height : delegate.height
            property Item contextMenu
            property bool menuOpen: contextMenu != null && contextMenu.parent === bgdelegate

            function remove() {
                var removal = removalComponent.createObject(bgdelegate)
                removal.execute(delegate,qsTr("Deleting ") + fileName, function() { _fm.remove(filePath); })
            }

            ListItem {
                id: delegate

                showMenuOnPressAndHold: false
                menu: myMenu
                visible : {
                    if (onlyFolders && fileIsDir) return true
                    else if (onlyFolders) return false
                    else return true
                }

                function showContextMenu() {
                    if (!contextMenu)
                        contextMenu = myMenu.createObject(view)
                    contextMenu.show(bgdelegate)
                }

                Image
                {
                    id: fileIcon
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    source: fileIsDir ? "image://theme/icon-m-folder" : "image://theme/icon-m-document"
                }

                Label {
                    id: fileLabel
                    anchors.left: fileIcon.right
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.top: fileInfo.text != "" ? parent.top : undefined
                    anchors.verticalCenter: fileInfo.text == "" ? parent.verticalCenter : undefined
                    text: fileName + (fileIsDir ? "/" : "")
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    width: mSelect.visible ? parent.width - (fileIcon.width + Theme.paddingLarge + Theme.paddingSmall + mSelect.width) : parent.width - (fileIcon.width + Theme.paddingLarge + Theme.paddingSmall)
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    id: fileInfo
                    visible: !fileIsDir
                    anchors.left: fileIcon.right
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.top: fileLabel.bottom
                    text: humanSize(fileSize) + ", " + fileModified
                    color: Theme.secondaryColor
                    width: parent.width - fileIcon.width - (Theme.paddingLarge + Theme.paddingSmall + Theme.paddingLarge)
                    truncationMode: TruncationMode.Fade
                }
                Switch {
                    id: mSelect
                    visible: fileIsDir && multiSelect && onlyFolders
                    anchors.right: parent.right
                    checked: false
                    onClicked: {
                        checked = !checked
                        fileOpen(filePath);
                        pageStack.pop();
                    }
                }

                onClicked: {
                    if(multiSelect)
                    {
                        mSelect.checked = !mSelect.checked
                        return;
                    }

                    if (fileIsDir) {
                        if (fileName === "..") fileModel.folder = fileModel.parentFolder
                        else if (fileName === ".") return
                        else fileModel.folder = filePath
                    } else {
                        if (!selectMode) openFile(filePath)
                        else {
                            fileOpen(filePath);
                            pageStack.pop();
                        }
                    }
                }
                onPressAndHold: showContextMenu()
            }

            Component {
                id: removalComponent
                RemorseItem {
                    id: remorse
                    onCanceled: destroy()
                }
            }

            Component {
                id: myMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: {
                            bgdelegate.remove();
                        }
                    }
                }
            }

        }
        VerticalScrollDecorator { flickable: view }
    }

}
