import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: historyPage

    property QtObject dataContainer
    property ListModel modelHistory
    allowedOrientations: Orientation.All


    SilicaListView {
        id: historyView
        anchors.fill: parent
        model: modelHistory

        VerticalScrollDecorator {}

        header: PageHeader {
            id: historyHead
            title: qsTr("History")
        }

        delegate: ListItem {
            id: listItem

            width: parent.width

            Label {
                x: Theme.paddingLarge
                text: htitle
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Theme.paddingMedium * 2
                truncationMode: TruncationMode.Fade
            }
            onClicked: {
                dataContainer.streamUrl = hurl
                dataContainer.loadPlayer();
            }
        }
        ViewPlaceholder {
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingLarge
            text: qsTr("No History")
            enabled: historyView.count == 0
        }
    }
    Component.onCompleted: historyView.scrollToBottom()

}
