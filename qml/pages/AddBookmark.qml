import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: addBookmarkPage

    allowedOrientations: Orientation.All

    acceptDestinationAction: PageStackAction.Pop

    onAccepted: addBookmark();

    property bool editBookmark: false
    property string oldTitle;
    property alias bookmarkTitle: bookmarkTitle.text
    property alias bookmarkUrl: bookmarkUrl.text
    property alias liveStream: liveStream.checked

    property ListModel bookmarks

    // Easy fix only for when http:// or https:// is missing
    function fixUrl(nonFixedUrl) {
        var valid = nonFixedUrl
        if (valid.indexOf(":")<0) {
            return "http://"+valid;
        } else return valid
    }

    function addBookmark() {
        if (editBookmark && oldTitle != "") bookmarks.editBookmark(oldTitle,bookmarkTitle.text,bookmarkUrl.text.toString(), liveStream.checked);
        else bookmarks.addBookmark(bookmarkUrl.text.toString(), bookmarkTitle.text, liveStream.checked);
    }

    Flickable {
        width:parent.width
        height: parent.height
        contentHeight: col.height + head.height

        DialogHeader {
            id: head
            acceptText: editBookmark ? qsTr("Edit Bookmark") : qsTr("Add Bookmark")
        }

        Column {
            id: col
            anchors.top: head.bottom
            anchors.topMargin: 25
            width: parent.width
            spacing: 25
            function enterPress() {
                if (bookmarkTitle.focus == true && editBookmark == false) bookmarkUrl.focus = true
                else if (bookmarkUrl.focus == true) { bookmarkUrl.text = fixUrl(bookmarkUrl.text);}
                else if (bookmarkTitle.focus == true && editBookmark == true) { accepted(); pageStack.pop(); }
            }

            TextField {
                id: bookmarkTitle
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 20
                placeholderText: "Title of the bookmark"
                focus: true
                label: qsTr("Title of the bookmark")
            }
            TextField {
                id: bookmarkUrl
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                placeholderText: "URL of bookmark"
                inputMethodHints: Qt.ImhUrlCharactersOnly
                visible: /*editBookmark ? false :*/ true
                label: qsTr("URL of bookmark")
            }
            Keys.onEnterPressed: enterPress();
            Keys.onReturnPressed: enterPress();
            TextSwitch {
                id: liveStream
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Live Stream")
            }
        }
    }

}
