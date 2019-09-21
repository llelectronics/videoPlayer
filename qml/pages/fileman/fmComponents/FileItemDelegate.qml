import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: bgdelegate
    width: parent.width
    height: menuOpen ? contextMenu.height + delegate.height : delegate.height
    property Item contextMenu
    property alias fileIcon: fileIcon
    property bool menuOpen: contextMenu != null && contextMenu.parent === bgdelegate

    function remove() {
        var removal = removalComponent.createObject(bgdelegate)
        var toDelPath = filePath
        if (fileIsDir)
            removal.execute(delegate,qsTr("Deleting ") + fileName, function() { _fm.removeDir(toDelPath); })
        else
            removal.execute(delegate,qsTr("Deleting ") + fileName, function() { _fm.remove(toDelPath); })
    }

    function copy() {
        _fm.moveMode = false;
        _fm.sourceUrl = filePath;
        //console.debug(_fm.sourceUrl)
    }

    function move() {
        _fm.moveMode = true;
        _fm.sourceUrl = filePath;
    }

    ListItem {
        id: delegate

        contentHeight: fileLabel.height + fileInfo.height + Theme.paddingSmall
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
            source: {
                if (fileIsDir) "image://theme/icon-m-folder"
                else if (_fm.getMime(filePath).indexOf("video") !== -1) "image://theme/icon-m-file-video"
                else if (_fm.getMime(filePath).indexOf("audio") !== -1) "image://theme/icon-m-file-audio"
                else if (_fm.getMime(filePath).indexOf("image") !== -1) "image://theme/icon-m-file-image"
                else if (_fm.getMime(filePath).indexOf("text") !== -1) "image://theme/icon-m-file-document"
                else if (_fm.getMime(filePath).indexOf("pdf") !== -1) "image://theme/icon-m-file-pdf"
                else if (_fm.getMime(filePath).indexOf("android") !== -1) "image://theme/icon-m-file-apk"
                else if (_fm.getMime(filePath).indexOf("rpm") !== -1) "image://theme/icon-m-file-rpm"
                else "image://theme/icon-m-document"
            }
        }

        Label {
            id: fileLabel
            anchors.left: fileIcon.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.top: fileInfo.text != "" ? parent.top : undefined
            anchors.verticalCenter: fileInfo.text == "" ? parent.verticalCenter : undefined
            text: fileName //+ (fileIsDir ? "/" : "")
            color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            width: mSelect.visible ? parent.width - (fileIcon.width + Theme.paddingLarge + Theme.paddingSmall + mSelect.width) : parent.width - (fileIcon.width + Theme.paddingLarge + Theme.paddingSmall)
            truncationMode: TruncationMode.Fade
        }
        Label {
            id: fileInfo
            anchors.left: fileIcon.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.top: fileLabel.bottom
            text: fileIsDir ? fileModified.toLocaleString() : humanSize(fileSize) + ", " + fileModified.toLocaleString()
            color: Theme.secondaryColor
            width: parent.width - fileIcon.width - (Theme.paddingLarge + Theme.paddingSmall + Theme.paddingLarge)
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeTiny
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
                var anotherFM = pageStack.push(Qt.resolvedUrl("../OpenDialog.qml"), {"path": filePath, "_sortField": _sortField, "dataContainer": dataContainer, "selectMode": selectMode, "multiSelect": multiSelect});
                anotherFM.fileOpen.connect(fileOpen)
            } else {
                if (!selectMode) openFile(filePath)
                else {
                    fileOpen(filePath);
                    pageStack.pop(dataContainer);
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
                text: qsTr("Cut")
                onClicked: {
                    bgdelegate.move();
                }
            }
            MenuItem {
                text: qsTr("Copy")
                onClicked: {
                    bgdelegate.copy();
                }
            }
            MenuItem {
                text: qsTr("Delete")
                onClicked: {
                    bgdelegate.remove();
                }
            }
            MenuItem {
                text: qsTr("Properties")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("FileProperties.qml"), {"path": filePath, dataContainer: dataContainer, "fileIcon": fileIcon.source, "fileSize": humanSize(fileSize), "fileModified": fileModified, "fileIsDir": fileIsDir, "father": page})
                }
            }
        }
    }

}

