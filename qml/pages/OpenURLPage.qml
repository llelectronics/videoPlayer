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
        title: drawer.open ? "History" : "Open"
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
                if (!mainWindow.firstPage.youtubeDirect) mainWindow.firstPage.streamUrl = urlField.text.toString()
                else mainWindow.firstPage.originalUrl = urlField.text.toString()
                pageStack.pop(dataContainer);
            }
        }
        else {
            if (dataContainer != null) {
                mainWindow.firstPage.streamUrl = urlField.text;
                mainWindow.firstPage.streamTitle = "";
                pageStack.pop(dataContainer);//, PageStackAction.Immediate);
            }
        }
    }

    Component.onCompleted: {
        //console.debug("Load history...")
        DB.getHistory();
    }

    Keys.onEnterPressed: loadUrl();
    Keys.onReturnPressed: loadUrl();

    function addHistory(url) {
        //console.debug("Adding " + url);
        historyModel.append({"hurl": url});
    }

    ListModel {
        id: historyModel
    }

    Drawer {
        id: drawer

        width: parent.width
        height: parent.height - header.height
        anchors.bottom: parent.bottom
        //anchors.fill: parent

        dock: openUrlPage.isPortrait ? Dock.Top : Dock.Left

        background: SilicaListView {
            anchors.fill: parent
            model: historyModel

            // Not necessary now. Later maybe removing all history
            //            PullDownMenu {
            //                MenuItem {
            //                    text: "Option 1"
            //                }
            //                MenuItem {
            //                    text: "Option 2"
            //                }
            //            }
            VerticalScrollDecorator {}

            delegate: ListItem {
                id: listItem

                Label {
                    x: Theme.paddingLarge
                    text: hurl
                    anchors.verticalCenter: parent.verticalCenter
                    color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    urlField.text = hurl
                    drawer.open = !drawer.open
                    //openUrlPage.loadUrl(); // No autoload for the moment. TODO: Maybe a thing for global settings
                }
            }
        }

        MouseArea {
            enabled: drawer.open
            anchors.fill: column
            onClicked: drawer.open = false
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
                id: historyBtn
                anchors.left: urlField.left
                anchors.top: urlField.bottom
                text: "History"
                onClicked: {
                    //DB.getHistory();
                    drawer.open = !drawer.open
                }
            }

            Button {
                id: openFileBtn
                anchors.top: urlField.bottom
                anchors.right: urlField.right
                text: "Browse Files"
                visible: true
                onClicked: {
                    if (mainWindow.firstPage.openDialogType === "adv") pageStack.replace(Qt.resolvedUrl("fileman/Main.qml"), {dataContainer: mainWindow.firstPage});
                    else if (mainWindow.firstPage.openDialogType === "gallery") pageStack.replace(mainWindow.firstPage.videoPickerComponent);
                    else if (mainWindow.firstPage.openDialogType === "simple") pageStack.replace(mainWindow.firstPage.openDialog);
                }
            }

            Button {
                id: addToBookmarkBtn
                anchors.top: historyBtn.bottom
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
}
