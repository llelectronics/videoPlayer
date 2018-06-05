import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    property QtObject father

    property string rootDir: "/"
    property string sdCardDir: _fm.getSDCard()

    property string homeDir: _fm.getHome()
    property string docDir: _fm.documents_dir()
    property string dowDir: _fm.getHome() + "/Downloads"
    property string musDir: _fm.getHome() + "/Music"
    property string picDir: _fm.getHome() + "/Pictures"
    property string vidDir: _fm.getHome() + "/Videos"

    property var devicesModel: [
         {
            name: qsTr("Phone memory"),
            path: rootDir,
            icon: "image://theme/icon-m-phone"
        },
        {
            name: qsTr("SD Card"),
            path: sdCardDir,
            icon: "../../img/sdcard.png",
        }
    ]

    property var placesModel: [
        {
            name: qsTr("Home"),
            path: homeDir,
            icon: "image://theme/icon-m-person"
        },
        {
            name: qsTr("Documents"),
            path: docDir,
            icon: "image://theme/icon-m-document"
        },
        {
            name: qsTr("Downloads"),
            path: dowDir,
            icon: "image://theme/icon-m-cloud-download"
        },
        {
            name: qsTr("Music"),
            path: musDir,
            icon: "image://theme/icon-m-sounds"
        },
        {
            name: qsTr("Pictures"),
            path: picDir,
            icon: "image://theme/icon-m-image"
        },
        {
            name: qsTr("Videos"),
            path: vidDir,
            icon: "image://theme/icon-m-media"
        }
    ]
    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: head
            title: qsTr("Places")
        }

        // Section Device
        Item {
            id: secDevices
            width: parent.width
            height: devicesList.height
            anchors.top: head.bottom
            anchors.topMargin: Theme.paddingSmall
            clip: true

            Behavior on height { NumberAnimation { duration: 150 } }

            SectionHeader { id: devicesHeader; text: qsTr("Devices") }

            SilicaListView {
                id: devicesList
                anchors.top: devicesHeader.bottom
                width: parent.width
                height: count * (Theme.itemSizeSmall + Theme.paddingLarge * 2)

                interactive: false
                model: devicesModel
                delegate: DirEntryDelegate {
                    property var item: model.modelData ? model.modelData : model
                    enabled: item.path !== ""
                    opacity: enabled? 1 : 0.5
                    icon: item.icon
                    text: item.name
                    onClicked: {
                        if (father.path!==item.path) {
                            father.path = item.path
                        }
                        pageStack.navigateBack()
                    }
                }
            }
        }
        // End Section Device

        // Section Places
        Item {
            id: secPlaces
            clip: true
            width: parent.width
            height: placesList.height
            anchors.top: secDevices.bottom
            anchors.topMargin: Theme.paddingSmall

            Behavior on height { NumberAnimation { duration: 150 } }

            SectionHeader { id: placesHeader; text: qsTr("Common") }

            SilicaListView {
                id: placesList
                anchors.top: placesHeader.bottom
                height: count * (Theme.itemSizeSmall + Theme.paddingLarge * 2)
                width: parent.width
                model: placesModel
                delegate: DirEntryDelegate {
                    property var item: model.modelData ? model.modelData : model
                    icon: item.icon
                    text: item.name
                    onClicked: {
                        if (father.path!==item.path) {
                            father.path = item.path
                        }
                        pageStack.navigateBack()
                    }
                }
            }
        }
        // End Section Places

    }
}
