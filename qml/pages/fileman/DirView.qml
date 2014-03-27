import QtQuick 2.0
import Sailfish.Silica 1.0
import Mer.Cutes 1.1
import "Bridge.js" as Util

Page {
    id : dirViewPage
    allowedOrientations: Orientation.All
    property int entriesCount: dirStack.count
    property string currentDirectory
    property QtObject dataContainer

    onStatusChanged : {
        switch (status) {
        case PageStatus.Activating: {
            currentDirectory = root;
            if (dirList.state !== "loaded")
                dirList.state = "load";
            break;
        }
        }
    }

    property string home: Util.getHome()
    property string root: "/home/nemo/Videos" // A sane default here for Videos

    function reloadList() {
        dirList.state = "load";
    }

    DirList {
        id: dirList
        home: dirViewPage.home

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: dirStackList.top
            bottomMargin: Theme.paddingLarge
        }

        onIsUsableChanged : {
            if (dirList.isUsable)
                dirViewPage.setupDirStack(dirList.root);
        }

        onMediaFileOpen: {
            //console.debug("DirView MediaFileOpen:" + url);
            dataContainer.streamUrl = url;
            dataContainer.streamTitle = "";
        }
        onFileRemove: {
            console.debug("[DirView]Requesting removal of file " + url);
            dataContainer.removeFile(url);
        }
    }

    ListModel {
        id: dirStack
    }

    function popToDirectory(pos) {
        console.log("Pop ", pos);
        var end = dirStack.count;
        var pos = end - pos - 1;
        if (!pos)
            return;
        var p = pageStack.find(function(p) {
            console.log("P:", p.root);
            return (pos-- == 0);
        });
        pageStack.pop(p);
    }

    DirStack {
        id: dirStackList
        model: dirStack
        height: Theme.itemSizeLarge
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }

    function setupDirStack(d) {
        dirStack.clear();
        if (d === "")
            return;

        Util.dirStack(d, {done: function(res) {
            Util.forEach(res, function(v) { dirStack.append({name: v}); });
            var count = dirStackList.count;
            if (count)
                dirStackList.currentIndex = count - 1;
        }});
    }

    Component.onCompleted: {
        dirList.root = (root !== "" ? root : Util.getRoot());
        console.debug(dataContainer)
    }

}
