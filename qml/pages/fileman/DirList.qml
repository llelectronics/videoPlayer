import Mer.Cutes 1.1
import QtQuick 2.0
import Sailfish.Silica 1.0
import "Bridge.js" as Util

SilicaListView {

    id: entriesList

    property string home: Util.getHome()
    property string root: ""

    // when all content is loaded
    property bool isLoaded: false

    // when visible part of the list is filled
    property bool isUsable: false

    // how many values needed to prefill the list covering visible
    // area. In a correct way it should be calculated
    property int usableCount: 15

    // it should be amount of items can be received w/o affecting
    // interactivity (operation execution time < ~0.1s)
    property int reasonableCount: 50

    // used to avoid sending request for more data from callback
    signal dataAdded

    signal mediaFileOpen(string url)

    Component {
        id: mainHeader
        PageHeader {
            title: entriesList.root
        }
    }

    header: mainHeader

    ListModel {
        id: entries
    }

    model: entries

    function showAbove(pages, params, immediate) {
        if (!isLoaded)
            state = "interrupted";
        pageStack.push(pages, params, immediate);
    }

    function goHome() {
        var os = cutes.require('os');
        if (os.path.isSame(root, home))
            return;

        var parts = os.path.split(home);
        var url = Qt.resolvedUrl('DirView.qml');
        var pages = [];
        var path = "";

        Util.forEach(parts, function(p) {
            path = os.path(path, p);
            pages.push({page: url, properties: {root: path, dataContainer: dataContainer}});
        });

        entriesList.showAbove(pages);
    }
    
    function goAndroidSd() {
        var url = Qt.resolvedUrl('DirView.qml');
        var pages = [];
        var path = "/data/sdcard";

        pages.push({page: url, properties: {root: path, dataContainer: dataContainer}});

        entriesList.showAbove(pages);
    }

    onDataAdded: requestData(reasonableCount)

    function requestData(count, is_refresh) {
        var requestMoreIfAny = function(info) {
            if (!info) {
                isLoaded = true;
            } else if (state === 'loading') {
                dataAdded();
            }
            isUsable = true;
        };

        Util.listDir({dir: entriesList.root, refresh: is_refresh
                      , begin: entries.count, len: count}
                    , {on_done: requestMoreIfAny
                       , on_progress: entries.append});
    }

    states: [
        State {
            name: "load"
            StateChangeScript {
                script: {
                    Util.waitOperationCompleted();
                    entries.clear();
                    requestData(usableCount, true);
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
        , State {
            name: "loading"
            when: isUsable && dirViewPage.status === PageStatus.Active
            StateChangeScript {
                script: {
                    dataAdded();
                }
            }
        }
        , State {
            name: "usable"
            when: isUsable
        }
    ]

    function showStoredPaths() {
        entriesList.showAbove(Qt.resolvedUrl("StoredPathsPage.qml")
                              , {destination: entriesList.root});
    }

    PullDownMenu {
        MenuItem {
            text: "Show Home"
            onClicked: entriesList.goHome()
        }
        MenuItem {
	    text: "Show Android sdcard"
	    onClicked: entriesList.goAndroidSd()
	}
        MenuItem {
            text: "Marked Paths"
            onClicked: entriesList.showStoredPaths()
        }
    }

    RemorsePopup {
        id: deleteRemorse
    }

    function getFullName(fileName) {
        return Util.path(entriesList.root, fileName);
    }

    delegate: DirEntry {
        myList: entriesList
        onMediaFileOpen: {
            console.debug("DirList MediaFileOpen:"+ url);
            entriesList.mediaFileOpen(url);
        }
    }

    VerticalScrollDecorator {}

}
