import QtQuick 2.0
import Sailfish.Silica 1.0
import "helper/yt.js" as YT

Page {
    id: fileDetails
    property alias filename: fileName.text
    property alias title: fileTitle.text
    property alias videocodec: fileVcodec.text
    property alias resolution: fileResolution.text
    property alias videobitrate: fileVbitrate.text
    property alias framerate: fileFramerate.text
    property alias audiocodec: fileAudiocodec.text
    property alias audiobitrate: fileAbitrate.text
    property alias samplerate: fileAsamplerate.text
    property alias copyright: fileCopyright.text
    property alias date: fileDate.text
    property alias size: fileSize.text
    property alias artist: fileArtist.text

    allowedOrientations: Orientation.All

    function returnArtist4WebSearch() {
        if (fileArtist.text != "") return fileArtist.text
        else return fileTitle.text
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: items.height + (items.height / 8)
        contentWidth: parent.width

        PullDownMenu {
            MenuItem {
                text: qsTr("Search Artist on Wikipedia")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"), {dataContainer: mainWindow.firstPage, websiteUrl: "http://en.m.wikipedia.org/w/index.php?search=" + fileDetails.returnArtist4WebSearch(), searchUrl: "http://en.m.wikipedia.org/w/index.php?search="});
            }
            MenuItem {
                text: qsTr("Search Artist on Google Image")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"), {dataContainer: mainWindow.firstPage, websiteUrl: "https://www.google.com/search?tbm=isch&q=" + fileDetails.returnArtist4WebSearch(), searchUrl: "https://www.google.com/search?tbm=isch&q="});
            }
            MenuItem {
                text: qsTr("Download Youtube Video")
                visible: {
                    if ((/^http:\/\/ytapi.com/).test(mainWindow.firstPage.streamUrl)) return true
                    else if (mainWindow.firstPage.isYtUrl) return true
                    else return false
                }
                //onClicked: pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": streamUrl, "downloadName": streamTitle});
                // Alternatively use direct youtube url instead of ytapi for downloads (ytapi links not always download with download manager)
                onClicked: {
                    // Filter out all chars that might stop the download manager from downloading the file
                    // Illegal chars: `~!@#$%^&*()-=+\|/?.>,<;:'"[{]}
                    //console.debug("[FileDetails -> Download YT Video]: " + mainWindow.firstPage.youtubeDirectUrl)
                    mainWindow.firstPage.streamTitle = YT.getDownloadableTitleString(mainWindow.firstPage.streamTitle)
                    pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": mainWindow.firstPage.youtubeDirectUrl, "downloadName": mainWindow.firstPage.streamTitle});
                }
            }
            MenuItem {
                text: qsTr("Add to bookmarks")
                visible: {
                    if (mainWindow.firstPage.streamTitle != "" || mainWindow.firstPage.streamUrl != "") return true
                    else return false
                }
                onClicked: {
                    if (mainWindow.firstPage.streamTitle != "") mainWindow.modelBookmarks.addBookmark(mainWindow.firstPage.streamUrl,mainWindow.firstPage.streamTitle)
                    else mainWindow.modelBookmarks.addBookmark(mainWindow.firstPage.streamUrl,mainWindow.firstPage.findBaseName(mainWindow.firstPage.streamUrl))
                }
            }
        }


        Item {
            id: items
            width: parent.width
            height: childrenRect.height

            Label {
                id: fileNameLbl
                font.bold: true
                text: "Filename: "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: parent.top
                anchors.topMargin: 105
            }
            TextArea {
                id: fileName
                anchors.left: fileNameLbl.right
                anchors.leftMargin: 15
                anchors.top: fileNameLbl.top
                width: parent.width - fileNameLbl.width - 40
                readOnly: true

            }
            Label {
                id: fileTitleLbl
                font.bold: true
                text: "Title: "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileName.bottom
                anchors.topMargin: 5
            }
            Label {
                id: fileTitle
                anchors.left: fileTitleLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileTitleLbl.verticalCenter
                width: parent.width - fileTitleLbl.width - 40
                elide: Text.ElideRight
                truncationMode: TruncationMode.Fade
            }
            Label {
                id: fileArtistLbl
                font.bold: true
                text: "Artist: "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileTitleLbl.bottom
                anchors.topMargin: 20
            }
            Label {
                id: fileArtist
                anchors.left: fileTitleLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileArtistLbl.verticalCenter
                width: parent.width - fileArtistLbl.width - 40
                elide: Text.ElideRight
                truncationMode: TruncationMode.Fade
            }
            Label {
                id: fileVcodecLbl
                font.bold: true
                text: "Videocodec: "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileArtistLbl.bottom
                anchors.topMargin: 20
                truncationMode: TruncationMode.Elide
            }
            Label {
                id: fileVcodec
                anchors.left: fileVcodecLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileVcodecLbl.verticalCenter
                width: parent.width - fileVcodecLbl.width - 40
                elide: Text.ElideRight
                truncationMode: TruncationMode.Fade
            }
            Label {
                id: fileResolutionLbl
                font.bold: true
                text: "Resolution: "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileVcodecLbl.bottom
                anchors.topMargin: 20
            }
            Label {
                id: fileResolution
                anchors.left: fileResolutionLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileResolutionLbl.verticalCenter
            }
            Label {
                id: fileVbitrateLbl
                font.bold: true
                text: "Videobitrate (bits/sec): "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileResolutionLbl.bottom
                anchors.topMargin: 20
            }
            Label {
                id: fileVbitrate
                anchors.left: fileVbitrateLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileVbitrateLbl.verticalCenter
            }
            Label {
                id: fileFramerateLbl
                font.bold: true
                text: "Framerate: "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileVbitrateLbl.bottom
                anchors.topMargin: 20
            }
            Label {
                id: fileFramerate
                anchors.left: fileFramerateLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileFramerateLbl.verticalCenter
            }
            Label {
                id: fileAudiocodecLbl
                font.bold: true
                text: "Audiocodec: "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileFramerateLbl.bottom
                anchors.topMargin: 20
            }
            Label {
                id: fileAudiocodec
                anchors.left: fileAudiocodecLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileAudiocodecLbl.verticalCenter
                width: parent.width - fileAudiocodecLbl.width - 40
                elide: Text.ElideRight
                truncationMode: TruncationMode.Fade
            }
            Label {
                id: fileAbitrateLbl
                font.bold: true
                text: "Audiobitrate (bits/sec): "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileAudiocodecLbl.bottom
                anchors.topMargin: 20
            }
            Label {
                id: fileAbitrate
                anchors.left: fileAbitrateLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileAbitrateLbl.verticalCenter
            }
            Label {
                id: fileAsamplerateLbl
                font.bold: true
                text: "Samplerate: "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileAbitrateLbl.bottom
                anchors.topMargin: 20
            }
            Label {
                id: fileAsamplerate
                anchors.left: fileAsamplerateLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileAsamplerateLbl.verticalCenter
            }
            Label {
                id: fileCopyrightLbl
                font.bold: true
                text: "Copyright: "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileAsamplerateLbl.bottom
                anchors.topMargin: 20
            }
            Label {
                id: fileCopyright
                anchors.left: fileCopyrightLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileCopyrightLbl.verticalCenter
                width: parent.width - fileCopyrightLbl.width - 40
                elide: Text.ElideRight
                truncationMode: TruncationMode.Fade
            }
            Label {
                id: fileDateLbl
                font.bold: true
                text: "Date: "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileCopyrightLbl.bottom
                anchors.topMargin: 20
            }
            Label {
                id: fileDate
                anchors.left: fileDateLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileDateLbl.verticalCenter
            }
            Label {
                id: fileSizeLbl
                font.bold: true
                text: "File size: "
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.top: fileDateLbl.bottom
                anchors.topMargin: 20
            }
            Label {
                id: fileSize
                anchors.left: fileSizeLbl.right
                anchors.leftMargin: 15
                anchors.verticalCenter: fileSizeLbl.verticalCenter
            }
        }
    }

}
