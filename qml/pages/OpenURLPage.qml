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
        acceptText: qsTr("Load URL")
    }

    onAccepted: loadUrl()
    onCanceled: pageStack.replace(dataContainer)

    function isUrl(url) {
        var pattern = new RegExp(/^(([\w]+:)?\/\/)?(([\d\w]|%[a-fA-f\d]{2,2})+(:([\d\w]|%[a-fA-f\d]{2,2})+)?@)?([\d\w][-\d\w]{0,253}[\d\w]\.)+[\w]{2,4}(:[\d]+)?(\/([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)*(\?(&?([-+_~.\d\w]|%[a-fA-f\d]{2,2})=?)*)?(#([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)?$/);
        if(!pattern.test(url)) {
            console.debug("Not a valid URL.");
            return false;
        } else {
            return true;
        }
    }

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
            if (isUrl(urlField.text.toString()) === true) {
                // Call C++ side here to grab url
                _ytdl.setUrl(urlField.text.toString());
                streamUrl = _ytdl.getStreamUrl();
                if (dataContainer != null) {
                    mainWindow.firstPage.streamUrl = streamUrl;
                    mainWindow.firstPage.originalUrl = urlField.text.toString();
                    mainWindow.firstPage.streamTitle = "";
                    mainWindow.firstPage.loadPlayer();
                }
            }
          else if (dataContainer != null) {
                mainWindow.firstPage.streamUrl = urlField.text;
                mainWindow.firstPage.originalUrl = "";
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
        width:parent.width
        height: isLandscape ? parent.height - Theme.paddingLarge * 4 : parent.height - Theme.paddingLarge * 6
        anchors.top: parent.top
        anchors.topMargin: isLandscape ? Theme.paddingLarge * 4 : Theme.paddingLarge * 6

        TextField {
            id: urlField
            placeholderText: qsTr("Type in URL here")
            label: qsTr("URL to media file/stream")
            width: Screen.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
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
