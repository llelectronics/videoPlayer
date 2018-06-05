import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property string path

    // return value
    property string errorMessage
    property QtObject father

    id: dialog
    allowedOrientations: Orientation.All

    property int _executeWidth: executeLabel.width

    onAccepted: {
        var isPermissionChanged = _fm.chmod(path,
                        ownerRead.checked, ownerWrite.checked, ownerExecute.checked,
                        groupRead.checked, groupWrite.checked, groupExecute.checked,
                        othersRead.checked, othersWrite.checked, othersExecute.checked);
        if (!isPermissionChanged) errorMessage = qsTr("Could not change permission")
    }

    // copy values to fields when page shows up
    Component.onCompleted: {
        ownerName.text = father.fileData.owner
        groupName.text = father. fileData.group
        var permissions = father.fileData.permissions
        if (permissions.charAt(0) !== '-') ownerRead.checked = true;
        if (permissions.charAt(1) !== '-') ownerWrite.checked = true;
        if (permissions.charAt(2) !== '-') ownerExecute.checked = true;
        if (permissions.charAt(3) !== '-') groupRead.checked = true;
        if (permissions.charAt(4) !== '-') groupWrite.checked = true;
        if (permissions.charAt(5) !== '-') groupExecute.checked = true;
        if (permissions.charAt(6) !== '-') othersRead.checked = true;
        if (permissions.charAt(7) !== '-') othersWrite.checked = true;
        if (permissions.charAt(8) !== '-') othersExecute.checked = true;
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height
        VerticalScrollDecorator { flickable: flickable }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right

            DialogHeader {
                id: dialogHeader
                title: qsTr("Change Permissions")
                acceptText: qsTr("Change")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                text: qsTr("Change permissions for") + "\n" + path
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
            }

            Separator {
                height: 2*Theme.paddingLarge
                color: "transparent"
            }

            // read, write, execute small labels
            Row {
                width: parent.width
                Label {
                    width: parent.width/2 - 2*Theme.paddingLarge
                    text: " "
                }

                Label {
                    id: readLabel
                    width: executeLabel.width
                    text: qsTr("Read")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    id: writeLabel
                    width: executeLabel.width
                    text: qsTr("Write")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    id: executeLabel
                    text: qsTr("Execute")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // owner
            Row {
                width: parent.width
                Column {
                    width: parent.width/2 - 2 * Theme.paddingLarge
                    Label {
                        id: ownerName
                        width: parent.width - Theme.paddingLarge
                        text: ""
                        color: Theme.highlightColor
                        horizontalAlignment: Text.AlignRight
                    }
                    Label {
                        width: parent.width - Theme.paddingLarge
                        text: qsTr("Owner")
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                        horizontalAlignment: Text.AlignRight
                    }
                }
                LetterSwitch {
                    id: ownerRead
                    width: _executeWidth
                    letter: 'r'
                }
                LetterSwitch {
                    id: ownerWrite
                    width: _executeWidth
                    letter: 'w'
                }
                LetterSwitch {
                    id: ownerExecute
                    width: _executeWidth
                    letter: 'x'
                }
            }

            // group
            Row {
                id: groupRow
                width: parent.width
                Column {
                    width: parent.width/2 - 2 * Theme.paddingLarge
                    Label {
                        id: groupName
                        width: parent.width - Theme.paddingLarge
                        text: ""
                        color: Theme.highlightColor
                        horizontalAlignment: Text.AlignRight
                    }
                    Label {
                        width: parent.width - Theme.paddingLarge
                        text: qsTr("Group")
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                        horizontalAlignment: Text.AlignRight
                    }
                }
                LetterSwitch {
                    id: groupRead
                    width: _executeWidth
                    letter: 'r'
                }
                LetterSwitch {
                    id: groupWrite
                    width: _executeWidth
                    letter: 'w'
                }
                LetterSwitch {
                    id: groupExecute
                    width: _executeWidth
                    letter: 'x'
                }
            }

            // others
            Row {
                width: parent.width
                height: groupRow.height
                Item {
                    width: parent.width/2 - 2 * Theme.paddingLarge
                    height: parent.height
                    Label {
                        width: parent.width - Theme.paddingLarge
                        height: parent.height
                        text: qsTr("Others")
                        color: Theme.highlightColor
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                LetterSwitch {
                    id: othersRead
                    width: _executeWidth
                    letter: 'r'
                }
                LetterSwitch {
                    id: othersWrite
                    width: _executeWidth
                    letter: 'w'
                }
                LetterSwitch {
                    id: othersExecute
                    width: _executeWidth
                    letter: 'x'
                }
            }
        }
    }
}
