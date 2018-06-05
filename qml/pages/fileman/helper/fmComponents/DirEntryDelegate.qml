import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: dirEntryDelegate

    property string icon: ""
    property alias text: label.text
    property bool delButtonVisible: false
    signal delButtonPressed()

    width: parent.width
    contentHeight: Theme.itemSizeSmall
    highlighted: down

    Image {
        id: image
        height: parent.height -Theme.paddingMedium
        width: height
        source: icon
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
    }

    Label {
        id: label
        width: parent.width
        truncationMode: TruncationMode.Fade
        color: Theme.primaryColor
        anchors.left: icon !== ""? image.right : parent.left
        anchors.leftMargin: icon !== ""? Theme.paddingMedium : Theme.paddingLarge
        anchors.right: delButtonVisible? delButton.left : parent.right
        anchors.rightMargin: Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
    }

    IconButton {
        id: delButton
        visible: delButtonVisible
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        height: parent.height
        width: height
        icon.source: "image://theme/icon-m-clear"
        opacity: 0.75
        onClicked: delButtonPressed()
    }

}
