import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaListView {
    id: dirStackList
    orientation: ListView.Horizontal
    model: dirStack
    delegate : ListItem {
        height: Theme.itemSizeMedium
        width: entryItem.width
        Row {
            id: entryItem
            spacing: Theme.paddingLarge
            anchors {
                verticalCenter: parent.verticalCenter
            }
            Label {
                text: name
                font.pixelSize: Theme.fontSizeMedium
                width: paintedWidth //+ Theme.paddingMedium
                horizontalAlignment:  Text.AlignHCenter
                anchors {
                    verticalCenter: parent.verticalCenter
                }
            }
            Image {
                id: auxLabel
                source: "image://theme/icon-m-right"
                anchors {
                    verticalCenter: parent.verticalCenter
                }
            }
            // Label {
            //     text: '/'
            //     font.pixelSize: Theme.fontSizeMedium
            //     width: paintedWidth + Theme.paddingLarge
            // }
        }
        onClicked: {
            //console.log("Click on ", name, index);
            popToDirectory(index);
        }
    }
    HorizontalScrollDecorator {}
}
