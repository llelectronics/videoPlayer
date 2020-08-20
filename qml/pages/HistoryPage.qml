import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    property QtObject dataContainer
    property ListModel modelHistory

    PageHeader {
        id: historyHead
        title: qsTr("History")
    }

    SilicaListView {
        id: historyView
        anchors.fill: parent
        model: modelHistory
        verticalLayoutDirection: ListView.BottomToTop

        VerticalScrollDecorator {}

        delegate: ListItem {
            id: listItem

            Label {
                x: Theme.paddingLarge
                text: htitle
                anchors.verticalCenter: parent.verticalCenter
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
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

}
