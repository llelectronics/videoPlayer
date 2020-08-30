import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    id: root
    allowedOrientations: Orientation.All

    property QtObject father

    property string rootDir: "/"
    property string sdCardDir: _fm.getSDCard()

    property string homeDir: _fm.getHome()
    property string docDir: _fm.documents_dir()
    property string dowDir: _fm.getHome() + "/Downloads"
    property string musDir: _fm.getHome() + "/Music"
    property string picDir: _fm.getHome() + "/Pictures"
    property string vidDir: _fm.getHome() + "/Videos"

    property var customPlaces: father.customPlaces
    //        [
    //        {
    //        name: qsTr("Device memory"),
    //        path: rootDir,
    //        icon: "image://theme/icon-m-phone"
    //        }
    //        ]
    
    ListModel {
        id: pickerModel

        ListElement {
            name: qsTr("Documents")
            uid: "docDir"
            ico: "image://theme/icon-m-document"
        }
        ListElement {
            name: qsTr("Downloads")
            uid: "dowDir"
            ico: "image://theme/icon-m-cloud-download"
        }
        ListElement {
            name: qsTr("Music")
            uid: "musDir"
            ico: "image://theme/icon-m-sounds"
        }
        ListElement {
            name: qsTr("Pictures")
            uid: "picDir"
            ico: "image://theme/icon-m-image"
        }
        ListElement {
            name: qsTr("Videos")
            uid: "vidDir"
            ico: "image://theme/icon-m-media"
        }
    }

    property var devicesModel: [
         {
            name: qsTr("Device memory"),
            path: rootDir,
            icon: "image://theme/icon-m-phone"
        },
        {
            name: qsTr("SD Card"),
            path: sdCardDir,
            icon: "image://theme/icon-m-sd-card",
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
        },
        {
            name: qsTr("Android Storage"),
            path: _fm.getHome() + "/android_storage",
            icon: "image://theme/icon-m-file-apk"
        }
    ]

    ConfigurationGroup {
        id: customPlacesSettings
        path: "/apps/harbour-llsfileman" // DO NOT CHANGE to share custom places between apps
    }

    Component.onCompleted: {
        var customPlacesJSON = customPlacesSettings.value("places","")
        var customPlacesObj = JSON.parse(customPlacesJSON)
        for (var i=0; i<customPlacesObj.length; i++) {
            var Name = customPlacesObj[i].name;
            var Path = customPlacesObj[i].path;
            var Icon = customPlacesObj[i].icon;
            customPlaces.push(
                        {
                            name: Name,
                            path: Path,
                            icon: Icon
                        }
                        )
        }
        customPlacesChanged()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: head.height + pickerSection.height + secDevices.height + secPlaces.height + cusPlaces.height + Theme.paddingLarge

        PageHeader {
            id: head
            title: qsTr("Places")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Search")
                onClicked: {
                    pageStack.navigateBack(PageStackAction.Immediate)
                    father.openSearch();
                }
            }
        }
        
        // Pickers
        Item {
            id: pickerSection
            width: parent.width
            height: pickersGrid.height
            anchors.top: head.bottom
            anchors.topMargin: Theme.paddingSmall
            clip: true
            
            SectionHeader { id: dataHeader; text: qsTr("Data") }

            Row {
                id: pickersGrid
                anchors.top: dataHeader.bottom
                height: childrenRect.height
                width: parent.width - Theme.paddingMedium * 2
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                spacing: (parent.width - 7*(Theme.iconSizeMedium+Theme.paddingMedium)) / 8
                Repeater {
                    model: pickerModel
                    height: delegate.height
                    delegate: Item {
                        width: (Theme.itemSizeMedium > icoLbl.width) ? Theme.itemSizeMedium : icoLbl.width
                        height: childrenRect.height + icoLbl.height + Theme.paddingLarge * 2
                        anchors.leftMargin: Theme.paddingMedium
                        anchors.rightMargin: Theme.paddingMedium

                        IconButton {
                            id: icoButton
                            height: Theme.iconSizeMedium
                            width: Theme.iconSizeMedium
                            icon.source: ico
                            onClicked: father.openPicker(uid)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Rectangle {
                            id: icoButtonCircle
                            width: icoButton.width + Theme.paddingMedium
                            height: icoButton.height + Theme.paddingMedium
                            color: "transparent"
                            border.color: Theme.primaryColor
                            border.width: 2
                            radius: width / 2
                            anchors.centerIn: icoButton
                        }

                        Label {
                            id: icoLbl
                            anchors.top: icoButton.bottom
                            anchors.topMargin: Theme.paddingLarge
                            text: name
                            truncationMode: TruncationMode.Fade
                            font.pixelSize: Theme.fontSizeTiny
                            anchors.horizontalCenter: icoButton.horizontalCenter
                        }
                    } // Item
                } // Repeater
                
            }
        }

        // Section Device
        Item {
            id: secDevices
            width: parent.width
            height: devicesList.height + devicesHeader.height
            anchors.top: pickerSection.bottom
            anchors.topMargin: Theme.paddingSmall
            clip: true

            Behavior on height { NumberAnimation { duration: 150 } }

            SectionHeader { id: devicesHeader; text: qsTr("Devices") }

            SilicaListView {
                id: devicesList
                anchors.top: devicesHeader.bottom
                width: parent.width
                height: count * (Theme.itemSizeSmall)

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
            height: placesList.height + placesHeader.height
            anchors.top: secDevices.bottom
            anchors.topMargin: Theme.paddingSmall

            Behavior on height { NumberAnimation { duration: 150 } }

            SectionHeader { id: placesHeader; text: qsTr("Common") }

            SilicaListView {
                id: placesList
                anchors.top: placesHeader.bottom
                height: count * (Theme.itemSizeSmall)
                width: parent.width
                model: placesModel
                delegate: DirEntryDelegate {
                    property var item: model.modelData ? model.modelData : model
                    icon: item.icon
                    text: item.name
                    height: Theme.itemSizeSmall
                    onClicked: {
                        if (father.path!==item.path) {
                            father.path = item.path
                        }
                        pageStack.navigateBack()
                    }
                    visible: {
                        if (item.icon === "image://theme/icon-m-file-apk") {
                            if (_fm.existsPath(_fm.getHome() + "/android_storage")) {
                                return true
                            }
                            else
                                return false

                        }
                        else return true
                    }
                }
            }
        }
        // End Section Places

        // Section Custom Places
        Item {
            id: cusPlaces
            clip: true
            width: parent.width
            height: cusPlacesList.height + cusPlacesHeader.height
            anchors.top: secPlaces.bottom
            anchors.topMargin: Theme.paddingSmall
            visible: cusPlacesList.count > 0

            Behavior on height { NumberAnimation { duration: 150 } }

            SectionHeader { id: cusPlacesHeader; text: qsTr("Custom") }

            SilicaListView {
                id: cusPlacesList
                anchors.top: cusPlacesHeader.bottom
                height: count * (Theme.itemSizeSmall)
                width: parent.width
                model: customPlaces
                delegate: DirEntryDelegate {
                    id: delegate
                    objectName: "delegate"
                    property bool menuOpen: contextMenu != null && contextMenu.parent === delegate
                    height: menuOpen ? contextMenu.height + Theme.itemSizeSmall : Theme.itemSizeSmall
                    property Item contextMenu
                    delButtonVisible: true
                    property var item: model.modelData ? model.modelData : model
                    icon: item.icon
                    text: item.name

                    function remove() {
                        var removal = removalComponent.createObject(root, {"root": root})
                        removal.execute(delegate,qsTr("Deleting ") + item.name,
                                        function() {
                                            for (var i=0; i<root.customPlaces.length; i++) {
                                                var index = root.customPlaces[i].path.indexOf(item.path)
                                                if (index > -1) {
                                                    root.customPlaces.splice(i,1)
                                                }
                                            }
                                            root.father.customPlacesChanged();
                                        })
                    }

                    function showContextMenu() {
                        if (!contextMenu)
                            contextMenu = myMenu.createObject(root, {"root": root, "path" : item.path, "oldName": item.name})
                        contextMenu.show(delegate)
                    }

                    onClicked: {
                        if (father.path!==item.path) {
                            father.path = item.path
                        }
                        pageStack.navigateBack()
                    }
                    onDelButtonPressed: {
                        remove()
                    }
                    onPressAndHold: showContextMenu()

                    Component {
                        id: removalComponent
                        RemorseItem {
                            id: remorse
                            onCanceled: destroy()
                            property QtObject root
                        }
                    }

                    Component {
                        id: myMenu
                        ContextMenu {
                            property var oldName
                            property var path
                            property QtObject root
                            MenuItem {
                                text: qsTr("Rename")
                                onClicked: {
                                    var dialog = pageStack.push(Qt.resolvedUrl("RenameDialog.qml"),
                                                                { "path": path, "oldName": oldName })
                                    dialog.accepted.connect(function() {
                                        for (var i=0; i<root.customPlaces.length; i++) {
                                            var index = root.customPlaces[i].path.indexOf(path)
                                            if (index > -1) {
                                                root.customPlaces[i].name = dialog.newName
                                            }
                                        }
                                        root.father.customPlacesChanged();
                                    })
                                } // End onClicked
                            }
                        } // End ContextMenu
                    } // End Component
                } // End DirEntryDelegate
            }

        }
        // End Section Custom Places

    }
}
