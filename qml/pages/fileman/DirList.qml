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
    }

    model: entries

    function forEach(arr, fn) {
        var i;
        for (i = 0; i < arr.length; ++i)
            fn(arr[i]);
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
        var path = "/data/sdcard";

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
    }
    PushUpMenu {
        MenuItem {
            text: "Scroll to top"
            onClicked: entriesList.scrollToTop();
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
    }

    VerticalScrollDecorator {}

}
