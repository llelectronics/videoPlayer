import QtQuick 2.0
import Sailfish.Silica 1.0

ContextMenu {
    id : entryMenu

    property string fileName: ""
    property string fileType: ""
    property string fileInfo: ""
    property string filePath: ""
    signal mediaFileOpen(string url)
    signal fileRemove(string url)

    function removeFile(url) {
            //console.debug("[DirEntryMenu] Request removal of: " + url);
            fileRemove(url)
    }

    // Seems to work but Util.rm seems to fail somehow
    function deleteFile() {
        var fullName = filePath;
        var msg = qsTr("Deleting ") + fileName;
        // function executed as a remorse action does not capture context :(
        // so, save needed functions as locals
        var pos = index;
        var entryIremove = entryItem.removeFile;

        entryItem.remorseAction(msg, function() {
            entryIremove(fullName,pos);
        });

    }

    MenuItem {
        text: "Delete"
        onClicked: entryMenu.deleteFile()
    }
}
