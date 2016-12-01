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

    RemorsePopup {
        id: globalRemorse
    }

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
                Image {
                    id: playlistsLogo
                    anchors.right: _titleItem.left
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.iconSizeMedium
                    height: width
                    source: "images/icon-l-clipboard.png"
                }
            }
            ViewPlaceholder {
                enabled: modelPlaylist.count == 0 && !playlistPanel.open
                text: {
                    if (modelPlaylist.isNew && modelPlaylist.count == 0) qsTr("Please add tracks to playlist")
                    else qsTr("Please load or create playlist")
                }
            }
            VerticalScrollDecorator {}

            function removeAll() {
                globalRemorse.execute("Clearing Playlist", function() { modelPlaylist.clear(); } )
            }

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
                    text: qsTr("Clear Playlist")
                    visible: mainWindow.modelPlaylist.count > 0
                    onClicked: repeater1.removeAll();
                }

                MenuItem {
                    text: qsTr("Create Playlist")
                    onClicked: playlistPanel.open = true
                }
                MenuItem {
                    text: qsTr("Add to Playlist")
                    visible: mainWindow.modelPlaylist.isNew
                    onClicked: pageStack.push(add2PlaylistComponent);
                }
                MenuItem {
                    text: qsTr("Load Playlist")
                    onClicked: pageStack.push(openPlaylistComponent);
                }
                MenuItem {
                    text: qsTr("Save Playlist")
                    onClicked: {
                        var saveReturn
                        if (mainWindow.playlist.pllist != "")
                            saveReturn = mainWindow.playlist.save(mainWindow.playlist.pllist);
                        else
                            saveReturn = mainWindow.playlist.save("/home/nemo/Music/playlists/" + mainWindow.modelPlaylist.name + ".pls")
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
            onFileOpen: {
                //console.debug("Try loading playlist " + path);
                mainWindow.modelPlaylist.isNew = false;
                mainWindow.playlist.pllist = path;
                pageStack.pop();
            }
        }
    }

    Component {
        id: add2PlaylistComponent
        OpenDialog {
            path: "/home/nemo/Videos"
            filter: ["*.mp4", "*.mp3", "*.mkv", "*.ogg", "*.ogv", "*.flac", "*.wav", "*.m4a", "*.flv", "*.webm", "*.oga", "*.avi", "*.mov", "*.3gp", "*.mpg", "*.mpeg", "*.wmv", "*.wma", "*.dv", "*.m2v", "*.asf", "*.nsv"]
            onFileOpen: {
                mainWindow.modelPlaylist.addTrack(path);
                pageStack.pop();
            }
        }
    }

    DockedPanel {
        id: playlistPanel

        width: playlistPage.isPortrait ? parent.width : Theme.itemSizeExtraLarge + Theme.paddingLarge
        height: playlistPage.isPortrait ? Theme.itemSizeExtraLarge + Theme.paddingLarge : parent.height
        modal: true

        dock: playlistPage.isPortrait ? Dock.Bottom : Dock.Right
        onOpenChanged: {
            if (open) inputName.forceActiveFocus();
            else playlistPage.forceActiveFocus();
        }

        TextField {
            id: inputName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: lbl.bottom
            anchors.topMargin: Theme.paddingMedium
            width: parent.width - (Theme.paddingLarge * 2)
            placeholderText: "Enter Playlistname"
            label: "Playlist"
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            // Only allow Enter key to be pressed when text has been entered
            EnterKey.enabled: text.length > 0
            EnterKey.onClicked: {
                mainWindow.modelPlaylist.isNew = true
                mainWindow.modelPlaylist.name = text // Might be useful in the future
                mainWindow.playlist.pllist = "/home/nemo/Music/playlists/" + text + ".pls"
                playlistPanel.open = false
                Qt.inputMethod.hide();
                playlistPage.forceActiveFocus();
            }
        }
        Label {
            id: lbl
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingMedium
            width: parent.width - (Theme.paddingLarge * 2)
            anchors.margins: { left: Theme.paddingMedium; right: Theme.paddingMedium }
            color: Theme.secondaryColor
            wrapMode: TextEdit.WordWrap
            text: qsTr("Playlists are saved to /home/nemo/Music/playlists")
        }


    }
}

