import QtQuick 2.0
import Sailfish.Silica 1.0
import "yt.js" as YT

Page {
    id: openUrlPage
    allowedOrientations: Orientation.All
    property QtObject dataContainer
    property string streamUrl

    PageHeader {
        title: "Open Stream URL"
    }

    function loadUrl() {
        if (YT.checkYoutube(urlField.text.toString())=== true) {
            var yturl = YT.getYoutubeVid(urlField.text.toString());
            if (dataContainer != null) {
                dataContainer.streamUrl = yturl;
                pageStack.pop(undefined, PageStackAction.Immediate);
            }
        }
        else {
            if (dataContainer != null) {
                dataContainer.streamUrl = urlField.text;
                pageStack.pop(undefined, PageStackAction.Immediate);
            }
        }
    }

    Keys.onEnterPressed: loadUrl();
    Keys.onReturnPressed: loadUrl();

    TextField {
        id: urlField
        placeholderText: "Type in URL here"
        anchors.centerIn: parent
        width: Screen.width - 20
        focus: true
        Component.onCompleted: {
            // console.debug("StreamUrl :" + streamUrl) // DEBUG
            if (streamUrl !== "") {
                text = streamUrl;
                selectAll();
            }
        }
    }

    Button {
        id: loadBtn
        anchors.top: urlField.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Load Url"
        onClicked: {
            loadUrl();
        }
    }
}
