import QtQuick 2.0
import Sailfish.Silica 1.0
import "fileman"

Page
{
    id: playlistPage
    allowedOrientations: Orientation.All
    showNavigationIndicator: true
    forwardNavigation: false

    property string playlistTitle
    property QtObject dataContainer
    property ListModel modelPlaylist

    Column
    {
        //anchors.fill: parent
        width: parent.width
        height: parent.height
        spacing: Theme.paddingLarge

        SilicaListView {
            id: repeater1
            width: parent.width
            height: playlistPage.height - (Theme.paddingLarge)  //- entryURL.height - 2*65 //- bottomBar.height
            model: modelPlaylist
            header: PageHeader {
                id: topPanel
                title: qsTr("Playlists")
            }
            ViewPlaceholder {
                enabled: modelPlaylist.count == 0
                text: qsTr("Please load or create playlist")
            }
            VerticalScrollDecorator {}
            delegate: ListItem {
                id: myListItem
                property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
                property Item contextMenu

                height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

                function remove() {
                    var removal = removalComponent.createObject(myListItem)
                    ListView.remove.connect(removal.deleteAnimation.start)
                    removal.execute(contentItem, "Deleting " + title, function() { modelPlaylist.removeTrack(url); } )
                }
//                function editBookmark() {
//                    pageStack.push(Qt.resolvedUrl("AddBookmark.qml"), { bookmarks: modelBookmarks, editBookmark: true, bookmarkUrl: url, bookmarkTitle: title, oldTitle: title });
//                }

                BackgroundItem {
                    id: contentItem
                    Label {
                        text: title
                        anchors.verticalCenter: parent.verticalCenter
                        color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                        truncationMode: TruncationMode.Fade
                        width: parent.width - (Theme.paddingMedium * 2)
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.margins: { left: Theme.paddingMedium; right: Theme.paddingMedium }
                    }
                    onClicked: {
                        dataContainer.streamUrl = url;
                        mainWindow.modelPlaylist.current = index;
                        dataContainer.isPlaylist = true;
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
//                        MenuItem {
//                            text: qsTr("Edit")
//                            onClicked: {
//                                menu.parent.editBookmark();
//                            }
//                        }
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
                    text: qsTr("Load Playlist")
                    onClicked: pageStack.push(openPlaylistComponent);
                }
                MenuItem {
                    text: qsTr("Save Playlist")
                    onClicked: {
                        var saveReturn = mainWindow.playlist.save(mainWindow.playlist.pllist);
                        if (saveReturn) {
                            console.debug("Saved successfully!")
                            mainWindow.infoBanner.showText(qsTr("Playlist saved."))
                        }
                        else {
                            console.debug("Playlist saving failed with error message: " + mainWindow.playlist.getError())
                            mainWindow.playlist.clearError() // So that we can load new playlists
                        }
                    }
                    visible: mainWindow.modelPlaylist.count != 0
                }
            }
        }
    }

    Component {
        id: openPlaylistComponent
        OpenDialog {
            path: "/home/nemo/Music/playlists"
            filter: ["*.pls", "*.m3u"]
            onOpenFile: {
                //console.debug("Try loading playlist " + path);
                mainWindow.playlist.pllist = path;
                pageStack.pop();
            }
        }
    }
}

