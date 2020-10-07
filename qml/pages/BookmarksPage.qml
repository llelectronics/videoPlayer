import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: bookmarksPage
    allowedOrientations: Orientation.All
    showNavigationIndicator: true
    forwardNavigation: false

    property string bookmarkUrl
    property string bookmarkTitle
    property bool liveStream
    property QtObject dataContainer
    property ListModel modelBookmarks

    //property ListModel tabModel

    SilicaListView {
        id: repeater1
        anchors.fill: parent
        model: modelBookmarks
        header: PageHeader {
            id: topPanel
            title: qsTr("Bookmarks")
            Image {
                id: bookmarksLogo
                anchors.right: _titleItem.left
                anchors.rightMargin: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.iconSizeMedium
                height: width
                source: "images/icon-l-star.png"
            }
        }
        VerticalScrollDecorator {}
        delegate: ListItem {
            id: myListItem
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            property Item contextMenu

            width: parent.width
            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            function remove() {
                var removal = removalComponent.createObject(myListItem)
                ListView.remove.connect(removal.deleteAnimation.start)
                removal.execute(contentItem, "Deleting " + title, function() { modelBookmarks.removeBookmark(url); } )
            }
            function editBookmark() {
                pageStack.push(Qt.resolvedUrl("AddBookmark.qml"), { bookmarks: modelBookmarks, editBookmark: true, bookmarkUrl: url, bookmarkTitle: title, oldTitle: title, liveStream: liveStream });
            }

            BackgroundItem {
                id: contentItem
                width: parent.width
                Label {
                    text: title
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                    width: parent.width - Theme.paddingMedium * 2
                    truncationMode: TruncationMode.Fade
                }
                onClicked: {
                    dataContainer.streamUrl = url;
                    dataContainer.isLiveStream = liveStream
                    dataContainer.loadPlayer();
                }
                onPressAndHold: {
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(repeater1)
                    contextMenu.show(myListItem)
                }
            }
            Component {
                id: removalComponent
                RemorseItem {
                    property QtObject deleteAnimation: SequentialAnimation {
                        PropertyAction { target: myListItem; property: "ListView.delayRemove"; value: true }
                        NumberAnimation {
                            target: myListItem
                            properties: "height,opacity"; to: 0; duration: 300
                            easing.type: Easing.InOutQuad
                        }
                        PropertyAction { target: myListItem; property: "ListView.delayRemove"; value: false }
                    }
                    onCanceled: destroy();
                }
            }
            Component {
                id: contextMenuComponent
                ContextMenu {
                    id: menu
                    MenuItem {
                        text: qsTr("Edit")
                        onClicked: {
                            menu.parent.editBookmark();
                        }
                    }
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: {
                            menu.parent.remove();
                        }
                    }
                }
            }
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Add Bookmark")
                onClicked: pageStack.push(Qt.resolvedUrl("AddBookmark.qml"), { bookmarks: modelBookmarks });
            }
        }
    }
}

