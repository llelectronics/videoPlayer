import QtQuick 2.0
import Sailfish.Silica 1.0
Page {
    id: downloadManager
    allowedOrientations: Orientation.All
    property string downloadUrl
    //property alias downloadUrl: urlField.text

    Component.onCompleted: {
        if (downloadUrl != "") _manager.downloadUrl(downloadUrl)
    }

    Flickable {
        id: flick
        width:parent.width
        height: parent.height
        anchors.top: parent.top
        //        anchors.topMargin: Theme.paddingLarge * 3
        contentHeight: column1.height
        PullDownMenu {
            MenuItem {
                text: qsTr("Add Download")
                onClicked: pageStack.push(manualDownload);
            }
//            MenuItem {
//                text: qsTr("Show Details")
//                onClicked: pageStack.push(details);
//            }
        }

        Column{
            id: column1
            width: parent.width
            spacing: 15

            PageHeader {
                title: qsTr("Download Manager")
            }

            // A Container to group the url TextField with its download Button
            Component {
                id: manualDownload
                Page {

                    Column {
                        width: parent.width
                        spacing: 15
                        // A standard TextField for the url address
                        PageHeader {
                            title: qsTr("Add Download")
                        }

                        TextField {
                            id: urlField
                            anchors.topMargin: 65
                            width:parent.width
                            inputMethodHints: Qt.ImhUrlCharactersOnly
                            onFocusChanged: if (focus == true) selectAll();

                            placeholderText: qsTr("Enter URL to download")

                            // Disable the control button upon text input
                            onTextChanged: {
                                downloadButton.enabled = (text != "")
                            }
                        }

                        Keys.onReturnPressed: downloadButton.clicked(undefined)
                        Keys.onEnterPressed: downloadButton.clicked(undefined)

                        Button {
                            id: downloadButton

                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: 50

                            text: qsTr("Download")

                            // Start download from url on click
                            onClicked: { _manager.downloadUrl(urlField.text); downloadManager.downloadUrl = urlField.text ; pageStack.pop() }
                        }
                    }
                }
            }
            TextArea {
                id: toDownload
                anchors.topMargin: 65
                text: downloadUrl
                width: parent.width
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                readOnly: true
            }

            ProgressBar {
                width: parent.width
                maximumValue: _manager.progressTotal
                value: _manager.progressValue
                label: _manager.progressMessage
            }

            Button {
                id: abortButton
                visible: {
                    if (_manager.activeDownloads != 0) return true
                    else false
                }
                text: qsTr("Abort")
                onClicked: { _manager.downloadAbort(); toDownload.text = "" }
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: qsTr("Active Downloads: ") + (_manager.activeDownloads == 0 ? "none" : _manager.activeDownloads)
                color: Theme.primaryColor
            }

            Label {
                anchors.topMargin: 65
                text: qsTr("Status:")
                color: Theme.primaryColor
            }
            // A standard TextArea for the download status output
            TextArea {
                width: parent.width
                height: 145
                readOnly: true

                text: _manager.statusMessage

                color: Theme.primaryColor
            }
            Label {
                text: qsTr ("Errors:")
                color: Theme.primaryColor
            }
            // A standard TextArea for displaying error output
            TextArea {
                width: parent.width
                height: 125
                readOnly: true

                text: _manager.errorMessage
                color: Theme.primaryColor
            }


// TODO: Maybe handy when there is a download list
//            Component {
//                id: details
//                Page {
//                    Column {
//                        width: parent.width
//                        spacing: 15
//                        PageHeader {
//                            title: qsTr("Download Details")
//                        }

//                        Label {
//                            anchors.topMargin: 65
//                            text: qsTr("Status:")
//                            color: Theme.primaryColor
//                        }
//                        // A standard TextArea for the download status output
//                        TextArea {
//                            width: parent.width
//                            height: 145
//                            readOnly: true

//                            text: _manager.statusMessage

//                            color: Theme.primaryColor
//                        }
//                        Label {
//                            text: qsTr ("Errors:")
//                            color: Theme.primaryColor
//                        }
//                        // A standard TextArea for displaying error output
//                        TextArea {
//                            width: parent.width
//                            height: 125
//                            readOnly: true

//                            text: _manager.errorMessage
//                            color: Theme.primaryColor
//                        }
//                    }
//                }
//            }
        }
    }
}
