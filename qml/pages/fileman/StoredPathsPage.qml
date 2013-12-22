import Mer.Cutes 1.1
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import "Bridge.js" as Util

Page {
    id: storedPathsPage
    property string destination: ""
    property bool isProgress: false
    ListModel {
        id: storedPaths
        function changeAll(selected) {
            for (var i = 0; i < count; ++i) {
                var data = get(i)
                data.selected = selected
                set(i, data)
            }
        }
        function listAll() {
            var path = cutes.require('os').path;
            var res = [];
            for (var i = 0; i < count; ++i) {
                var data = get(i);
                if (data.selected)
                    res.push({
                        path: path(data.path, data.name)
                        , name: data.name
                        , position : i
                    });
            }
            return res;
        }
    }

    SilicaListView {
        id: storedPathsList

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: parent.top
        }

        clip: true
        model: storedPaths
        Component {
            id: myHeader
            Item {
                width: parent ? parent.width : screen.width
                height: Theme.itemSizeLarge + destinationItem.height
                PageHeader {
                    id: headerTitle
                    title: "Stored Paths"
                }
                TextField {
                    id: destinationItem
                    readOnly: true
                    text: storedPathsPage.destination
                    label: "Destination"
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: headerTitle.bottom
                        // bottom: parent.bottom
                        // bottomMargin: Theme.paddingLarge
                    }
                }
            }
        }
        header: myHeader

        function copySelected() {
            var data = [];
            Util.forEach(storedPaths.listAll(), function(info) {
                info.operation = "copy";
                info.destination = storedPathsPage.destination;
                data.push(info);
            });
            var p = pageStack.replace(Qt.resolvedUrl('ActionProgress.qml')
                                      , {request : data}
                                      , PageStackAction.Immediate);
            p.execute();
        }

        PullDownMenu {
            MenuItem {
                text: "Copy Selected"
                onClicked: storedPathsList.copySelected()
            }
            MenuItem {
                text: "Select All"
                onClicked: storedPaths.changeAll(true)
            }
            MenuItem {
                text: "Deselect All"
                onClicked: storedPaths.changeAll(false)
            }
        }

        Component.onCompleted: Util.pathRecall(function(v) {
            v.selected = false;
            storedPaths.append(v);
        })

        delegate: BackgroundItem {
            height: Theme.itemSizeLarge;

            TextSwitch {
                text: name
                description: path
                automaticCheck: false
                checked: selected
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    rightMargin: Theme.paddingLarge
                }
                onClicked: storedPaths.setProperty(index, "selected", !selected)
            }
        }
        VerticalScrollDecorator {}
    }
    ProgressBar {
        id: progressItem
        visible: isProgress
        indeterminate: true
        label: "----"
        anchors {
            left: parent.left
            right: parent.right
        }
    }
}
