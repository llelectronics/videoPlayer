import QtQuick 2.0
import Sailfish.Silica 1.0

// This component is a toggle switch, which displays a letter or a dash '-'
BackgroundItem {
    id: bgItem

    // checked status of the switch
    property bool checked: false

    // letter to be displayed
    property string letter: ""

    height: parent.height

    Label {
        id: label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: checked ? letter : "-"
        color: bgItem.highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    onClicked: checked = !checked
}
