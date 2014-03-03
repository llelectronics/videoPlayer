import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: bookmarksPage
    allowedOrientations: Orientation.All
    showNavigationIndicator: true
    forwardNavigation: false

    property string siteURL
    property string siteTitle
    property QtObject dataContainer
    property ListModel bookmarks

    //property ListModel tabModel

    ListModel {
        id:modelBookmarks

        function contains(siteUrl) {
            var suffix = "/";
            var str = siteUrl.toString();
            for (var i=0; i<count; i++) {
                if (get(i).url == str)  {
                    return true;
                }
                // check if url endswith '/' and return true if url-'/' = models url
                else if (str.indexOf(suffix, str.length - suffix.length) !== -1) {
                    if (get(i).url == str.substring(0, str.length-1)) return true;
                }
            }
            return false;
        }

        function editBookmark(oldTitle, siteTitle, siteUrl, agent) {
            for (var i=0; i<count; i++) {
                if (get(i).title === oldTitle) set(i,{"title":siteTitle, "url":siteUrl, "agent": agent});
            }
            DB.addBookmark(siteTitle,siteUrl,agent);
        }

        function removeBookmark(siteUrl) {
            for (var i=0; i<count; i++) {
                if (get(i).url === siteUrl) remove(i);
            }
            DB.removeBookmark(siteUrl);
        }

        function addBookmark(siteUrl, siteTitle, agent) {
            append({"title":siteTitle, "url":siteUrl, "agent":agent});
            DB.addBookmark(siteTitle,siteUrl,agent);
        }
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
            height: urlPage.height - (tabListView.height + Theme.paddingLarge)  //- entryURL.height - 2*65 //- bottomBar.height
            model: modelBookmarks
            header: PageHeader {
                id: topPanel
                title: qsTr("Bookmarks")
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
                    removal.execute(contentItem, "Deleting " + title, function() { bookmarks.removeBookmark(url); } )
                }
                function editBookmark() {
                    pageStack.push(Qt.resolvedUrl("AddBookmark.qml"), { bookmarks: urlPage.bookmarks, editBookmark: true, uAgent: agent, bookmarkUrl: url, bookmarkTitle: title, oldTitle: title });
                }

                BackgroundItem {
                    id: contentItem
                    Label {
                        text: title
                        anchors.verticalCenter: parent.verticalCenter
                        color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                    }
                    onClicked: {
                        dataContainer.streamUrl = url;
                        pageStack.pop();
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
                    text: qsTr("About ")+appname
                    onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
                }
                MenuItem {
                    text: qsTr("Add Bookmark")
                    onClicked: pageStack.push(Qt.resolvedUrl("AddBookmark.qml"), { bookmarks: urlPage.bookmarks });
                }
            }
        }
    }
}

