import Mer.Cutes 1.1
import QtQuick 2.0
import Sailfish.Silica 1.0
import "Bridge.js" as Util

ListItem {
    id: entryItem

    menu: myMenu
    property Item myList
    property string fileType: type
    property string fileName: name
    showMenuOnPressAndHold: false
    signal mediaFileOpen(string url)
    signal fileRemove(string url)

    Component {
        id: myMenu
        DirEntryMenu {
            onMediaFileOpen: {
                //console.debug("DirEntry MediaFileOpen:" + url)
                entryItem.mediaFileOpen(url)
            }
        }
    }

    function showContextMenu() {
        var filePath = getFullName(fileName);
        if (!Util.isSpecialPath(filePath))
            showMenu({fileName: fileName
                      , fileType: fileType
                      , filePath: getFullName(fileName)});
    }

    onClicked : {
        if (fileType === 'd') {
            var os = cutes.require('os');
            var d = os.qt.dir(myList.root);
            if (name === '..') {
                pageStack.pop();
                if (d.cdUp()) {
                    myList.root = d.path();
                }
            } else if (name !== '.') {
                var url = Qt.resolvedUrl('DirView.qml');
                myList.showAbove(url, {root: d.filePath(name), dataContainer: dataContainer });
            }
        } else {
            showContextMenu();
        }
    }
    onPressAndHold: showContextMenu()
    Item {
        id: infoLine
        height: Theme.itemSizeLarge
        width: parent.width
        anchors {
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }

        Image {
            id: entryIcon

            function getSource() {
                var sources = {
                    f : "image://theme/icon-m-document"
                    , d : "image://theme/icon-m-folder"
                    , s : "image://theme/icon-m-link"
                };
                return sources[fileType] || "image://theme/icon-m-other";
            }
            source: getSource()
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
        }

        Column {
            height: childrenRect.height
            anchors {
                verticalCenter: parent.verticalCenter
                //top: parent.top
                //topMargin: Theme.paddingSmall
                left: entryIcon.right
                right: auxLabel.left
                leftMargin: Theme.paddingSmall
                rightMargin: Theme.paddingMedium
            }

            Label {
                width: parent.width
                text: name
                font.pixelSize: Theme.fontSizeMedium
                elide: TruncationMode.Elide
                //truncationMode: TruncationMode.Elide
            }
            Label {
                width: parent.width
                id: infoLabel
                text: infoString()
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall

                function infoString() {
                    switch(fileType) {
                    case 'd':
                        return 'directory';
                    case 's': {
                        var fullName = myList.getFullName(fileName);
                        var fi = Util.fileInfo(fullName);
                        return '-> ' + fi.symLinkTarget();
                    }
                    default:
                        return fileSizeString();
                    }
                }

                function fileSizeString() {
                    var suffices = ['b', 'K', 'M', 'G', 'T'];
                    var s = size;
                    var i = 0;
                    while (s > 1024) {
                        s /= 1024;
                        ++i;
                    }
                    return (i < suffices.length)
                        ? String(s.toFixed(i < 2 ? 0 : 1)) + suffices[i]
                    : "?";
                }

            }

        }
        Image {
            id: auxLabel
            source: (fileType === 'd') ? "image://theme/icon-m-right" : ""
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
        }
    }

}
