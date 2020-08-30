import QtQuick 2.0
import Sailfish.Silica 1.0
Page {
    allowedOrientations: Orientation.All
    CreditsModel {id: credits}

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column1.height + Theme.paddingLarge

        Column{
            id: column1
            anchors.fill: parent
            anchors.topMargin: Theme.paddingLarge * 3
            spacing: Theme.paddingLarge

            Image{
                source: appicon
                height: Theme.iconSizeExtraLarge
                width: height
                fillMode: Image.PreserveAspectFit
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }
            Label {
                font.pixelSize: Theme.fontSizeMedium
                text: appname+" v"+version
                anchors.horizontalCenter: parent.horizontalCenter

            }
            Label {
                text: qsTr("License: BSD (3-clause)")
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle{
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#333333" }
                    GradientStop { position: 1.0; color: "#777777" }
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                height: 3
                width: parent.width-64
            }

            Label {
                width: 360
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("Created by: llelectronics")
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
            }

            Repeater{
                model: credits
                Label  {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: title
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
            Rectangle{
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#333333" }
                    GradientStop { position: 1.0; color: "#777777" }
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                height: 3
                width: parent.width-64
            }

            Label {
                id: homepage
                anchors.horizontalCenter: parent.horizontalCenter
                text: "<a href=\"https://github.com/llelectronics/videoPlayer\">Sourcecode</a>"
                onLinkActivated: Qt.openUrlExternally(link)
                linkColor: Theme.highlightColor
            }

            Label {
                width: parent.width-70
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("A simple video player based on GStreamer.")
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
                height: 200
                wrapMode: Text.WordWrap
            }
        }
    }
}
