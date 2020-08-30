import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property string path

    // return value
    property string errorMessage

    id: dialog
    allowedOrientations: Orientation.All
    canAccept: folderName.text !== ""

    onAccepted: {
        var isCreated = _fm.createDir(path + "/" + folderName.text)
        if (!isCreated) errorMessage = qsTr("Error creating new directory")
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
                title: qsTr("Create Folder")
                acceptText: qsTr("Create")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                text: qsTr("Create a new folder under") + "\n" + path
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }

            Separator {
                height: Theme.paddingLarge
                color: "transparent"
            }

            TextField {
                id: folderName
                width: parent.width
                placeholderText: qsTr("Folder name")
                label: qsTr("Folder name")
                focus: true

                // return key on virtual keyboard accepts the dialog
                EnterKey.enabled: folderName.text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: dialog.accept()
            }
        }
    }
}
