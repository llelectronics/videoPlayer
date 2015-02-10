import QtQuick 2.0
import Sailfish.Silica 1.0
import "helper/yt.js" as YT
import "helper/db.js" as DB

Dialog {
    id: openUrlPage
    allowedOrientations: Orientation.All
    property QtObject dataContainer
    property string streamUrl

    DialogHeader {
        id: header
        title: qsTr("Open URL")
    }

    onAccepted: loadUrl()
    onCanceled: pageStack.replace(dataContainer)

    function loadUrl() {
        if (YT.checkYoutube(urlField.text.toString())=== true) {
            //var yturl = YT.getYoutubeVid(urlField.text.toString());
            //            YT.getYoutubeTitle(urlField.text.toString());
            //            var ytID = YT.getYtID(urlField.text.toString());
            //            console.debug(ytID)
            //            YT.getYoutubeStream(ytID);
            if (dataContainer != null) {
                mainWindow.firstPage.streamUrl = urlField.text.toString();
                mainWindow.firstPage.originalUrl = urlField.text.toString();
                mainWindow.firstPage.loadPlayer();
            }
        }
        else {
            if (dataContainer != null) {
                mainWindow.firstPage.streamUrl = urlField.text;
                mainWindow.firstPage.streamTitle = "";
                mainWindow.firstPage.loadPlayer();
            }
        }
    }

    Keys.onEnterPressed: loadUrl();
    Keys.onReturnPressed: loadUrl();

    function addHistory(url) {
        //console.debug("Adding " + url);
        mainWindow.firstPage.historyModel.append({"hurl": url});
    }



    Item {
        id: column
        anchors.fill: parent

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
            id: addToBookmarkBtn
            anchors.top: urlField.bottom
            anchors.topMargin: 15
            //anchors.right: historyBtn.right
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Add to bookmarks"
            visible: {
                if (urlField.text !== "") return true
                else return false
            }
            onClicked: {
                pageStack.push(Qt.resolvedUrl("AddBookmark.qml"), { bookmarks: mainWindow.modelBookmarks, editBookmark: false, bookmarkUrl: urlField.text });
            }
        }

    }
}
