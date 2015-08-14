import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id : dirViewPage
    allowedOrientations: Orientation.All
    //property int entriesCount: dirStack.count
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

    property string home: _fm.getHome()
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
            bottom: parent.bottom
            //bottom: dirStackList.top
            //bottomMargin: Theme.paddingLarge
        }

        onIsUsableChanged : {
            if (dirList.isUsable)
                dirViewPage.setupDirStack(dirList.root);
        }

        onMediaFileOpen: {
            //console.debug("DirView MediaFileOpen:" + url);
            dataContainer.originalUrl = url;
            dataContainer.streamUrl = url;
            dataContainer.streamTitle = "";
            dataContainer.loadPlayer();
        }
        onFileRemove: {
            //console.debug("[DirView]Requesting removal of file " + url);
            _fm.remove(url);
        }
    }

    Component.onCompleted: {
        dirList.root = (root !== "" ? root : _fm.getRoot());
        //console.debug(dataContainer)
    }

}
