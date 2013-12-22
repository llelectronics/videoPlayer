import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: openUrlPage
    allowedOrientations: Orientation.All
    property QtObject dataContainer

    PageHeader {
        title: "Open Stream URL"
    }

    TextField {
        id: urlField
        placeholderText: "Type in URL here"
        anchors.centerIn: parent
        width: Screen.width - 20
    }

    Button {
        id: loadBtn
        anchors.top: urlField.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Load Url"
        onClicked: {
            if (dataContainer != null) {
                dataContainer.streamUrl = urlField.text;
                pageStack.pop(undefined, PageStackAction.Immediate)
            }
        }
    }
}
