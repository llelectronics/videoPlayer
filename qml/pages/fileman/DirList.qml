import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.videoplayer.Videoplayer 1.0

SilicaListView {

    id: entriesList

    property string home: _fm.getHome()
    property string root: ""

    // when all content is loaded
    property bool isLoaded: false

    // when visible part of the list is filled
    property bool isUsable: false

    signal mediaFileOpen(string url)
    signal fileRemove(string url)
    signal dirRemove(string url)
    signal addToPlaylist(string url)

    property bool isHidden: true

    Component {
        id: mainHeader
        PageHeader {
            title: entriesList.root
        }
    }

    header: mainHeader

    FolderListModel {
        id: entries
        folder: entriesList.root
        showDirsFirst: true
    }

    model: entries

    function forEachAddToPlaylist() {
        var i;
        for (i = 0; i < entries.count; ++i)
            if (!entries.isFolder(i))
                addToPlaylist(entries.get(i, "filePath"))
    }

    function showAbove(pages, params, immediate) {
        if (!isLoaded)
            state = "interrupted";
        pageStack.push(pages, params, immediate);
    }

    function goHome() {
        if (root == home)
            return;

        var url = Qt.resolvedUrl('DirView.qml');
        var pages = [];
        var path = home;

        pages.push({page: url, properties: {root: path, dataContainer: dataContainer}});

        entriesList.showAbove(pages);
    }
    
    function goAndroidSd() {
        var url = Qt.resolvedUrl('DirView.qml');
        var pages = [];
        var path = "/sdcard";

        pages.push({page: url, properties: {root: path, dataContainer: dataContainer}});

        entriesList.showAbove(pages);
    }

    function goRoot() {
        var url = Qt.resolvedUrl('DirView.qml');
        var pages = [];
        var path = "/";

        pages.push({page: url, properties: {root: path, dataContainer: dataContainer}});

        entriesList.showAbove(pages);
    }

    function goSd() {
        var url = Qt.resolvedUrl('DirView.qml');
        var pages = [];
        var path = "/media/sdcard";

        pages.push({page: url, properties: {root: path, dataContainer: dataContainer}});

        entriesList.showAbove(pages);
    }

    function showHidden() {   // Only works with Qt 5.2 and Qt.labs.folderlistmodel 2.1
        entries.showHidden = !entries.showHidden
        isHidden = !isHidden
    }

    function findBaseName(url) {
        url = url.toString();
        var fileName = url.substring(url.lastIndexOf('/') + 1);
        return fileName;
    }

    function findFullPath(url) {
        url = url.toString();
        var fullPath = url.substring(url.lastIndexOf('://') + 3);
        return fullPath;
    }

    states: [
        State {
            name: "load"
            StateChangeScript {
                script: {
                    //Util.waitOperationCompleted();  // Not necessary if requestData not working
                    //entries.clear();
                    //requestData(usableCount, true); // Not working currently so disabled
                }
            }
        }
        , State {
            name: "interrupted"
        }
        , State {
            name: "loaded"
            when: isLoaded
        }
//        , State {
//            name: "loading"
//            when: isUsable && dirViewPage.status === PageStatus.Active
//            StateChangeScript {
//                script: {
//                    dataAdded();
//                }
//            }
//        }
//        , State {
//            name: "usable"
//            when: isUsable
//        }
    ]

    PullDownMenu {
        MenuItem {
            text: "Add files to playlist"
            onClicked: {
                forEachAddToPlaylist();
                dataContainer.openPlaylist();
            }
        }
        MenuItem {
            text: isHidden ? "Show Hidden Files" : "Hide Hidden Files"
            onClicked: entriesList.showHidden();
        }
        MenuItem {
            text: "Show Filesystem Root"
            onClicked: entriesList.goRoot();
        }
        MenuItem {
            text: "Show Home"
            onClicked: entriesList.goHome();
        }
        MenuItem {
            text: "Show Android SDCard"
            onClicked: entriesList.goAndroidSd();
        }
        MenuItem {
            text: "Show SDCard"
            onClicked: entriesList.goSd();
            visible: _fm.existsPath("/media/sdcard")
            //Component.onCompleted: console.debug("[DirList] SD Card status: " + Util.existsPath("/media/sdcard"))
        }
        MenuItem {
            id: pasteMenuEntry
            visible: { if (_fm.sourceUrl != "" && _fm.sourceUrl != undefined) return true;
                else return false
            }
            text: qsTr("Paste") + "(" + findBaseName(_fm.sourceUrl) + ")"
            onClicked: {
                busyInd.running = true
                if (_fm.moveMode) {
                    //console.debug("Moving " + _fm.sourceUrl + " to " + root+ "/" + findBaseName(_fm.sourceUrl));
                    _fm.moveFile(_fm.sourceUrl,root + "/" + findBaseName(_fm.sourceUrl));
                }
                else {
                    //console.debug("Copy " + _fm.sourceUrl + " to " + root+ "/" + findBaseName(_fm.sourceUrl));
                    _fm.copyFile(_fm.sourceUrl,root + "/" + findBaseName(_fm.sourceUrl))
                }
            }
        }
    }
    PushUpMenu {
        MenuItem {
            text: "Scroll to top"
            onClicked: entriesList.scrollToTop();
        }
        MenuItem {
            text : "Show Playlist"
            onClicked: pageStack.push(Qt.resolvedUrl("../PlaylistPage.qml"), {dataContainer: mainWindow.firstPage, modelPlaylist: mainWindow.modelPlaylist});
        }
    }

    RemorsePopup {
        id: deleteRemorse
    }

    function getFullName(fileName) {
        return entriesList.root + '/' + fileName;
    }

    delegate: DirEntry {
        myList: entriesList
        onMediaFileOpen: {
            //console.debug("[DirList] MediaFileOpen:"+ url);
            entriesList.mediaFileOpen(url);
        }
        onFileRemove: {
            //console.debug("[DirList] Request removal of: " + url);
            entriesList.fileRemove(url);
        }
        onDirRemove: {
            entriesList.dirRemove(url);
        }
    }

    VerticalScrollDecorator {}

    Connections {
        target: _fm
        onSourceUrlChanged: {
            if (_fm.sourceUrl != "" && _fm.sourceUrl != undefined) {
                pasteMenuEntry.visible = true;
            }
            else pasteMenuEntry.visible = false;
        }
        onCpResultChanged: {
            if (!_fm.cpResult) {
                var message = qsTr("Error pasting file ") + _fm.sourceUrl
                console.debug(message);
                mainWindow.infoBanner.parent = dirViewPage
                mainWindow.infoBanner.anchors.top = dirViewPage.top
                infoBanner.showText(message)
            }
            else {
                _fm.sourceUrl = "";
                var message = qsTr("File operation succeeded")
                console.debug(message);
                mainWindow.infoBanner.parent = dirViewPage
                mainWindow.infoBanner.anchors.top = dirViewPage.top
                infoBanner.showText(message)
            }
            busyInd.running = false;
        }
    }

    BusyIndicator {
        id: busyInd
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingLarge
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
    }

}
