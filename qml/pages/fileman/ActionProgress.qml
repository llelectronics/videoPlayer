import Mer.Cutes 1.1
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import "Bridge.js" as Util

Page {
    id: actionProgress
    property variant request: null

    Timer {
        // at least execute() should be executed till the end
        property int remainedOperations: 1
        id: doneTimer
        // user should see at a glance results :)
        interval: 500
        running: remainedOperations == 0
        onTriggered: {
            var p = pageStack.previousPage();
            console.log("Go to", p.root, "@state=", p.state);
            p.reloadList();
            pageStack.pop();
        }
    }

    function execute() {
        Util.forEach(request, function(info) {
            console.log("Info:", info.name);
            info.isDone = false;
            actions.append(info);
            ++doneTimer.remainedOperations;
            switch (info.operation) {
            case "copy":
                Util.copy(info.path, info.destination, function() {
                    console.log("Done", info.position);
                    info.isDone = true;
                    actions.setProperty(info.position, "isDone", true);
                    --doneTimer.remainedOperations;

                });
                break;
            }
        });
        --doneTimer.remainedOperations;
    }

    ListModel {
        id: actions
    }

    SilicaListView {
        id: actionList
        anchors.fill: parent

        model: actions

        Component {
            id: myHeader
            PageHeader {
                id: headerTitle
                title: "Progress"
            }
        }

        header: myHeader

        delegate : ListItem {
            TextSwitch {
                text: isDone ? name : ""
                description: isDone ? "done" : ""
                automaticCheck: false
                checked: isDone
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            ProgressBar {
                id: progressItem
                visible: !isDone
                indeterminate: true
                label: name
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
        }
    }

}
