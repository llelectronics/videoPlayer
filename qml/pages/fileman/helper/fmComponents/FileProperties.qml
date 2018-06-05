import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: propertiesPage
    allowedOrientations: Orientation.All

    property string path;
    property string fileIcon;
    property string fileSize;
    property string fileModified;
    property bool fileIsDir;
    property var fileSizeDir: if (fileIsDir) { busyDirSize.running = true;  _fm.getDirSize(path) }
    property QtObject dataContainer;
    property QtObject father;

    property alias fileData: fileData

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height
        VerticalScrollDecorator { flickable: flickable }

        QtObject {
            id: fileData
            property string name: father.findBaseName((path).toString())
            property string fullPath: path
            property bool isSymLink: _fm.isSymLink(path.toString())
            property string symLinkTarget: _fm.getSymLinkTarget(path.toString())
            property bool isSymLinkBroken: {
                if (isSymLink && symLinkTarget != "") return false
                else return true
            }
            property string mimeType: _fm.getMime(path.toString())
            property string permissions: _fm.getPermissions(path.toString())
            property string owner: _fm.getOwner(path.toString())
            property string group: _fm.getGroup(path.toString())
        }

        // TODO: Implement

            PullDownMenu {
                MenuItem {
                    text: qsTr("Change Permissions")
                    onClicked: {
                        var dialog = pageStack.push(Qt.resolvedUrl("PermissionDialog.qml"),
                                                    { "path": path, "father": propertiesPage })
                        dialog.accepted.connect(function() {
                            if (dialog.errorMessage !== "") {
                                console.debug(dialog.errorMessage)
                                infoBanner.parent = propertiesPage
                                infoBanner.anchors.top = propertiesPage.top
                                infoBanner.showText(dialog.errorMessage)
                            }
                            else {
                                // Refresh
                                var oldPath = path
                                path = ""
                                path = oldPath
                            }
                        })
                    }
                }
                MenuItem {
                    text: qsTr("Rename")
                    onClicked: {
                        var dialog = pageStack.push(Qt.resolvedUrl("RenameDialog.qml"),
                                                    { "path": path, "oldName": fileData.name })
                        dialog.accepted.connect(function() {
                            if (dialog.errorMessage !== "") {
                                console.debug(dialog.errorMessage)
                                infoBanner.parent = propertiesPage
                                infoBanner.anchors.top = propertiesPage.top
                                infoBanner.showText(dialog.errorMessage)
                            }
                            else
                                propertiesPage.path = dialog.newPath;
                        })
                    }
                }
//                MenuItem {
//                    text: qsTr("View Contents")
//                    visible: !fileData.isDir
//                    onClicked: viewContents()
//                }

//                MenuItem {
//                    text: qsTr("Go to Target")
//                    visible: fileData.isSymLink && fileData.isDir
//                    onClicked: Functions.goToFolder(fileData.symLinkTarget);
//                }
            }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width

            PageHeader {
                title: qsTr("Properties")
                description: fileData.fullPath
            }

            // file info texts, visible if error is not set
            Column {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x

                // clickable icon and filename
                BackgroundItem {
                    id: openButton
                    width: parent.width
                    height: openArea.height
                    onClicked: {
                        if (!fileIsDir) {
                            father.openFile(path)
                        }
                    }

                    Column {
                        id: openArea
                        width: parent.width

                        Image { // preview of image, max height 400
                            id: imagePreview
                            visible: _fm.getMime(path).indexOf("image") !== -1
                            source: visible ? path : "" // access the source only if img is visible
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: implicitHeight < 400 * Theme.pixelRatio && implicitHeight != 0
                                    ? implicitHeight * Theme.pixelRatio
                                    : 400 * Theme.pixelRatio
                            width: parent.width
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                        }
                        Image {
                            id: icon
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: fileIcon
                            visible: !imagePreview.visible
                            width: 128 * Theme.pixelRatio
                            height: 128 * Theme.pixelRatio
                        }
                        Separator { // spacing if image or play button is visible
                            id: spacer
                            height: 24
                            visible: imagePreview.visible
                            color: "transparent"
                        }
                        Label {
                            id: filename
                            width: parent.width
                            text: fileData.name
                            textFormat: Text.PlainText
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                            color: openButton.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }
                        Label {
                            visible: fileData.isSymLink
                            width: parent.width
                            text: "\u2192 " +fileData.symLinkTarget
                            textFormat: Text.PlainText
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: fileData.isSymLinkBroken ? "red" :
                                                              (openButton.highlighted ? Theme.highlightColor
                                                                                      : Theme.primaryColor)
                        }
                        Separator { height: Theme.paddingLarge; color: "transparent" }
                    }
                }

                DetailItem {
                    label: qsTr("Location")
                    value: fileData.fullPath
                }
                DetailItem {
                    label: qsTr("Type")
                    value: fileData.isSymLink
                           ? qsTr("Link to %1").arg(fileData.symLinkTarget) + "\n("+fileData.mimeType+")"
                           : fileData.mimeType
                }
                DetailItem {
                    label: qsTr("Size")
                    value: {
                        if (fileIsDir) {
                            if (fileSizeDir != "-1") father.humanSize(fileSizeDir)
                            else "Calculating..."
                        }
                        else
                            fileSize
                    }
                    BusyIndicator {
                        id: busyDirSize
                        anchors.left: parent.left
                        anchors.leftMargin: parent.width - Theme.paddingLarge * 2
                        anchors.verticalCenter: parent.verticalCenter
                        visible: running
                        size: BusyIndicatorSize.ExtraSmall
                    }
                }
                DetailItem {
                    label: qsTr("Permissions")
                    value: fileData.permissions
                }
                DetailItem {
                    label: qsTr("Owner")
                    value: fileData.owner
                }
                DetailItem {
                    label: qsTr("Group")
                    value: fileData.group
                }
                DetailItem {
                    label: qsTr("Last modified")
                    value: fileModified
                }
            }
        }
    }
    Connections {
        target: _fm
        onDirSizeChanged: {
            busyDirSize.running = false
            //console.debug("DirSize: " + dirSize)
            fileSizeDir = dirSize
        }
    }
}
