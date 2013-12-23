import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: openUrlPage
    allowedOrientations: Orientation.All
    property QtObject dataContainer
    property string streamUrl

    PageHeader {
        title: "Open Stream URL"
    }

    TextField {
        id: urlField
        placeholderText: "Type in URL here"
        anchors.centerIn: parent
        width: Screen.width - 20
        Component.onCompleted: {
            if (streamUrl !== "") {
                text = streamUrl;
            }
        }
    }

    Button {
        id: loadBtn
        anchors.top: urlField.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Load Url"
        onClicked: {
            // Yeah I hate RegEx. Thx user2200660 for this nice youtube regex ;)
            if (urlField.text.toString().match('/?.*(?:youtu.be\\/|v\\/|u/\\w/|embed\\/|watch\\?.*&?v=)')) {
                console.debug("Youtube URL detected");
                var youtube_id;
                if (urlField.text.toString().match('embed')) { youtube_id = urlField.text.toString().split(/embed\//)[1].split('"')[0]; }
                else { youtube_id = urlField.text.toString().split(/v\/|v=|youtu\.be\//)[1].split(/[?&]/)[0]; }
                console.debug(youtube_id);

                urlField.text = "http://ytapi.com/?vid=" + youtube_id + "&format=direct";
            }

            if (dataContainer != null) {
                dataContainer.streamUrl = urlField.text;
                pageStack.pop(undefined, PageStackAction.Immediate)
            }
        }
    }
}
