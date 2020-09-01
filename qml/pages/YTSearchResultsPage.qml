import QtQuick 2.0
import Sailfish.Silica 1.0
import "helper"
import "helper/db.js" as DB

Page {
    id: ytSearchResultsPage

    allowedOrientations: Orientation.All

    property QtObject dataContainer
    property bool _isLandscape: (ytSearchResultsPage.orientation === Orientation.Landscape || ytSearchResultsPage.orientation === Orientation.LandscapeInverted)

    property QtObject _searchField

    ListModel {
        id: ytSearchResultsModel
//        ListElement {
//            titleYT: "NEPTUNE OS 6 : A Look at a nice Debian 10 based Linux Distribution"
//            thumbnailYT: "https://i.ytimg.com/vi_webp/P8R0YVyfN6E/maxresdefault.webp?v=5d8b4ec2"
//            channelNameYT: "Joe Loves Linux"
//            channelIdYT: "UCdI8plWGpNHwN1oswHi3iWA"
//            channelUrlYT: "http://www.youtube.com/channel/UCdI8plWGpNHwN1oswHi3iWA"
//            videoIdYT: "P8R0YVyfN6E"
//            videoUrlYT: "https://r2---sn-gx5oo1-ia1e.googlevideo.com/videoplayback?expire=1597675379&ei=E0M6X7bNJZKRmgeHkJm4Ag&ip=202.36.244.181&id=o-AIeyqJgsNzbXBeoLIlYP_w4lxoVtigxFfzIzjm_9roDG&itag=22&source=youtube&requiressl=yes&mh=17&mm=31%2C29&mn=sn-gx5oo1-ia1e%2Csn-ntq7yned&ms=au%2Crdu&mv=m&mvi=2&pl=24&initcwndbps=1626250&vprv=1&mime=video%2Fmp4&ratebypass=yes&dur=1166.965&lmt=1569410865192162&mt=1597653634&fvip=5&fexp=23883098&c=WEB&txp=2216222&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRQIhAKvtNxXpZUEodH9mZD4GPx1EFvuRqQhlV1Y02vj4ySCWAiAgyHVpk-m3kGf2Oggpl6KzAeSXZGfcAe1O5w1hMhfJDQ%3D%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRAIgHxVMtqO4SvR7KCfOWA0trt3uU63Wm-KztzcS6mClfPcCIBNj0Nnc8iWxvT7VoExvcg9fjwA5Jsfwz42jk_4CVTdJ"
//            durationYT: "1167"
//            uploadDateYT: "20190925"
//        }
//        ListElement {
//            titleYT: "Neptune OS: Debian Allesk\u00f6nner mit KDE | #Linux #Neptune #Plasma"
//            thumbnailYT: "https://i.ytimg.com/vi/mt0xmoP_0T0/maxresdefault.jpg"
//            channelNameYT: "linux made simple"
//            channelIdYT: "UCdHDE389WqZX-TP6wPN1Llg"
//            channelUrlYT: "http://www.youtube.com/channel/UCdHDE389WqZX-TP6wPN1Llg"
//            videoIdYT: "mt0xmoP_0T0"
//            videoUrlYT: "https://r1---sn-gx5oo1-ia1e.googlevideo.com/videoplayback?expire=1597675381&ei=FUM6X6HZM8XH1AbR_avwBA&ip=202.36.244.181&id=o-AGBkCvUKQZJnuWaZlh7uzx5STKVdJMlo_Css5P5G0YfA&itag=22&source=youtube&requiressl=yes&mh=kC&mm=31%2C29&mn=sn-gx5oo1-ia1e%2Csn-ntqe6n7k&ms=au%2Crdu&mv=m&mvi=1&pl=24&initcwndbps=1626250&vprv=1&mime=video%2Fmp4&ratebypass=yes&dur=1234.001&lmt=1584313723647993&mt=1597653634&fvip=5&fexp=23883098&c=WEB&txp=5432432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRQIhANnTVzt5icf86RKXud59huYDhbwE4u6tWAcSvLbAWBzxAiAkDR54fY27iq_D8qFaQNt524iajIOU0XHPocWFist64A%3D%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRQIgcQSjpJvFtDBl7A5mMNaN1VSpKM1iTIi8iXVlwJXFI9cCIQClZZee50AH5ioKpHH8QCAACi4OJayiKNlW6fTVn2km0g%3D%3D"
//            durationYT: "1234"
//            uploadDateYT: "20200712"
//        }
        function contains(id) {
            var str = id.toString();
            for (var i=0; i<count; i++) {
                if (get(i).videoIdYT === str)  {
                    return true;
                }
            }
            return false;
        }

    }

    SilicaFlickable {
        id: ytSearchResultsFlick
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Show Website")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"), {"dataContainer": dataContainer});
            }
        }

        PushUpMenu {
            id: pushUpYtSearchResultList
            MenuItem {
                text: qsTr("Load more")
                enabled: ytSearchResultsList.visible
                onClicked: {
                    mainWindow.firstPage.busy.visible = true;
                    mainWindow.firstPage.busy.running = true;
                    _ytdl.searchResultNumber = _ytdl.searchResultNumber * 2
                    _ytdl.getYtSearchResults(_searchField.acceptedInput)
                }
            }
        }

        PageHeader {
            id: pHead
            SearchField {
                id: searchField
                property string acceptedInput: ""
                width: parent.width

                placeholderText: qsTr("Search..")
                //                        anchors.top: parent.top
                //                        anchors.left: parent.left
                //                        anchors.right: parent.right

                EnterKey.enabled: text.trim().length > 0
                EnterKey.text: "Search"

                Component.onCompleted: {
                    acceptedInput = ""
                    _editor.accepted.connect(searchEntered)
                    ytSearchResultsPage._searchField = searchField
                }

                // is called when user presses the Return key
                function searchEntered() {
                    mainWindow.firstPage.busy.visible = true;
                    mainWindow.firstPage.busy.running = true;
                    ytSearchResultsModel.clear()
                    searchField.acceptedInput = text
                    _ytdl.getYtSearchResults(acceptedInput)
                    searchField.focus = false
                    // Search History adding
                    DB.addSearchHistory(text)
                    mainWindow.firstPage.addSearchHistory(text)
                }
            }
        }

        SectionHeader {
            id: recentSearchHeader
            anchors.top: pHead.bottom
            text: qsTr("Recent Searches")
            visible: searchHistoryList.visible
        }


    SilicaListView {
        id: ytSearchResultsList
        anchors.top: pHead.bottom
        width: parent.width
        height: parent.height - pHead.height
        model: ytSearchResultsModel
        visible: ytSearchResultsModel.count > 0
        clip: true

        delegate: YTSearchResultItem {
            id: yTSearchResultItem
            title: titleYT
            thumbnail: thumbnailYT
            channelName: channelNameYT
            channelId: channelIdYT
            channelUrl: channelUrlYT
            videoId: videoIdYT
            videoUrl: videoUrlYT
            duration: durationYT
            uploadDate: uploadDateYT
            url360p: url360pYT
            url720p: url720pYT
            url240p: url240pYT

            height: menuOpen ? contextMenu.height + _defaultHeight : _defaultHeight

            function downloadVideo() {
                pageStack.push(Qt.resolvedUrl("ytQualityChooser.qml"), {"streamTitle": titleYT, "url720p": url720pYT, "url480p": "", "url360p": url360pYT, "url240p": url240pYT, "ytDownload": true});
            }

            function add2playlist() {
                mainWindow.infoBanner.parent = ytSearchResultsPage
                mainWindow.infoBanner.anchors.top = ytSearchResultsPage.top
                mainWindow.infoBanner.showText(titleYT + " " + qsTr("added to playlist"));
                mainWindow.modelPlaylist.addTrack(videoUrlYT,titleYT);
            }

            property bool menuOpen: contextMenu != null && contextMenu.parent === yTSearchResultItem
            property Item contextMenu

            onLongPressed: {
                if (!contextMenu)
                    contextMenu = contextMenuComponent.createObject(ytSearchResultsList)
                contextMenu.show(yTSearchResultItem)
            }

            Component {
                id: contextMenuComponent
                ContextMenu {
                    id: menu
                    MenuItem {
                        text: qsTr("Add to playlist")
                        onClicked: {
                            menu.parent.add2playlist();
                        }
                    }
                    MenuItem {
                        text: qsTr("Download")
                        onClicked: {
                            menu.parent.downloadVideo()
                        }
                    }
                }
            }
        }
    }



        // Search History List
        SilicaListView {
            id: searchHistoryList
            width: parent.width
            height: parent.height - recentSearchHeader.height - pHead.height
            anchors.top: recentSearchHeader.bottom
            model: mainWindow.firstPage.searchHistoryModel
            visible: !ytSearchResultsList.visible

            clip: true

            VerticalScrollDecorator {}

            verticalLayoutDirection: ListView.BottomToTop

            delegate: ListItem {
                id: listItem

                Label {
                    x: Theme.paddingLarge
                    text: searchTerm
                    anchors.verticalCenter: parent.verticalCenter
                    color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    ytSearchResultsPage._searchField.text = searchTerm
                    ytSearchResultsPage._searchField.searchEntered()
                }
            }
            ViewPlaceholder {
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingLarge
                text: qsTr("No Search History")
                enabled: searchHistoryList.count == 0
            }
        }
        // End of Search History List

        Component.onCompleted: searchHistoryList.scrollToTop()

    }


    Connections {
        target: _ytdl
        onYtSearchResultsChanged: {
            console.debug("Got search results. Set busy false")
            mainWindow.firstPage.busy.visible = false;
            mainWindow.firstPage.busy.running = false;
            if (ytSearchResultsJson != "") {  // Don't load empty stuff
                var JsonObject = JSON.parse(ytSearchResultsJson)
                for (var i = 0; i < JsonObject.entries.length; i++){
                    //console.debug(JsonObject.entries[i]);
                    var yt360p = ""
                    var yt720p = ""
                    var yt240p = ""
                    for (var j = 0; j < JsonObject.entries[i].formats.length; j++) {
//                        console.debug("===DEBUG==== JsonObject.entries[i].formats[j].format_note:" + JsonObject.entries[i].formats[j].format_note)
//                        console.debug("===DEBUG==== JsonObject.entries[i].formats[j].ext:" + JsonObject.entries[i].formats[j].ext)
//                        console.debug("===DEBUG==== JsonObject.entries[i].formats[j].format_id:" + JsonObject.entries[i].formats[j].format_id)
                        if (JsonObject.entries[i].formats[j].format_note == "360p" &&
                                JsonObject.entries[i].formats[j].ext == "mp4" &&
                                JsonObject.entries[i].formats[j].format_id == "18") {
                            yt360p = JsonObject.entries[i].formats[j].url
                        }
                        if (JsonObject.entries[i].formats[j].format_note == "720p" &&
                                JsonObject.entries[i].formats[j].ext == "mp4" &&
                                JsonObject.entries[i].formats[j].format_id == "22") {
                            yt720p = JsonObject.entries[i].formats[j].url
                        }
                        if (JsonObject.entries[i].formats[j].format_note == "240p" &&
                                JsonObject.entries[i].formats[j].ext == "flv" &&
                                JsonObject.entries[i].formats[j].format_id == "36") {
                            yt240p = JsonObject.entries[i].formats[j].url
                        }
                    }
                    var defaultVideoUrl;
                    if (mainWindow.firstPage.ytQualWanted == "720p") defaultVideoUrl = yt720p;
                    else if (mainWindow.firstPage.ytQualWanted == "360p") defaultVideoUrl = yt360p;
                    else if (mainWindow.firstPage.ytQualWanted == "240p") defaultVideoUrl = yt240p;
                    else defaultVideoUrl = yt360p;
                    // Only append video ids that are not already in the list
                    if (!ytSearchResultsModel.contains(JsonObject.entries[i].id)) {
                        ytSearchResultsModel.append(
                                    {
                                        "titleYT": JsonObject.entries[i].title,
                                        "thumbnailYT": JsonObject.entries[i].thumbnail,
                                        "channelNameYT": JsonObject.entries[i].uploader,
                                        "channelIdYT": JsonObject.entries[i].channel_id,
                                        "channelUrlYT": JsonObject.entries[i].uploader_url,
                                        "videoIdYT": JsonObject.entries[i].id,
                                        "videoUrlYT": defaultVideoUrl,
                                        "durationYT": JsonObject.entries[i].duration.toString(),
                                        "uploadDateYT": JsonObject.entries[i].upload_date.toString(),
                                        "url720pYT": yt720p,
                                        "url360pYT": yt360p,
                                        "url240pYT": yt240p
                                    }
                                    ) // append End
                    }
                }
            }
            else {
                // Fail silently
                mainWindow.firstPage.busy.visible = false;
                mainWindow.firstPage.busy.running = false;
            }
        }
    }

}
