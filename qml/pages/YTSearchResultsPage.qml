import QtQuick 2.0
import Sailfish.Silica 1.0
import "helper"

Page {
    id: ytSearchResultsPage

    allowedOrientations: Orientation.All

    property QtObject dataContainer


    ListModel {
        id: exampleModel
        ListElement {
            titleYT: "NEPTUNE OS 6 : A Look at a nice Debian 10 based Linux Distribution"
            thumbnailYT: "https://i.ytimg.com/vi_webp/P8R0YVyfN6E/maxresdefault.webp?v=5d8b4ec2"
            channelNameYT: "UCdI8plWGpNHwN1oswHi3iWA"
            channelUrlYT: "http://www.youtube.com/channel/UCdI8plWGpNHwN1oswHi3iWA"
            videoIdYT: "P8R0YVyfN6E"
            videoUrlYT: "https://r2---sn-gx5oo1-ia1e.googlevideo.com/videoplayback?expire=1597675379&ei=E0M6X7bNJZKRmgeHkJm4Ag&ip=202.36.244.181&id=o-AIeyqJgsNzbXBeoLIlYP_w4lxoVtigxFfzIzjm_9roDG&itag=22&source=youtube&requiressl=yes&mh=17&mm=31%2C29&mn=sn-gx5oo1-ia1e%2Csn-ntq7yned&ms=au%2Crdu&mv=m&mvi=2&pl=24&initcwndbps=1626250&vprv=1&mime=video%2Fmp4&ratebypass=yes&dur=1166.965&lmt=1569410865192162&mt=1597653634&fvip=5&fexp=23883098&c=WEB&txp=2216222&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRQIhAKvtNxXpZUEodH9mZD4GPx1EFvuRqQhlV1Y02vj4ySCWAiAgyHVpk-m3kGf2Oggpl6KzAeSXZGfcAe1O5w1hMhfJDQ%3D%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRAIgHxVMtqO4SvR7KCfOWA0trt3uU63Wm-KztzcS6mClfPcCIBNj0Nnc8iWxvT7VoExvcg9fjwA5Jsfwz42jk_4CVTdJ"
            durationYT: "1167"
            uploadDateYT: "20190925"
        }
        ListElement {
            titleYT: "Neptune OS: Debian Allesk\u00f6nner mit KDE | #Linux #Neptune #Plasma"
            thumbnailYT: "https://i.ytimg.com/vi/mt0xmoP_0T0/maxresdefault.jpg"
            channelNameYT: "UCdHDE389WqZX-TP6wPN1Llg"
            channelUrlYT: "http://www.youtube.com/channel/UCdHDE389WqZX-TP6wPN1Llg"
            videoIdYT: "mt0xmoP_0T0"
            videoUrlYT: "https://r1---sn-gx5oo1-ia1e.googlevideo.com/videoplayback?expire=1597675381&ei=FUM6X6HZM8XH1AbR_avwBA&ip=202.36.244.181&id=o-AGBkCvUKQZJnuWaZlh7uzx5STKVdJMlo_Css5P5G0YfA&itag=22&source=youtube&requiressl=yes&mh=kC&mm=31%2C29&mn=sn-gx5oo1-ia1e%2Csn-ntqe6n7k&ms=au%2Crdu&mv=m&mvi=1&pl=24&initcwndbps=1626250&vprv=1&mime=video%2Fmp4&ratebypass=yes&dur=1234.001&lmt=1584313723647993&mt=1597653634&fvip=5&fexp=23883098&c=WEB&txp=5432432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRQIhANnTVzt5icf86RKXud59huYDhbwE4u6tWAcSvLbAWBzxAiAkDR54fY27iq_D8qFaQNt524iajIOU0XHPocWFist64A%3D%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRQIgcQSjpJvFtDBl7A5mMNaN1VSpKM1iTIi8iXVlwJXFI9cCIQClZZee50AH5ioKpHH8QCAACi4OJayiKNlW6fTVn2km0g%3D%3D"
            durationYT: "1234"
            uploadDateYT: "20200712"
        }

    }

    SilicaListView {
        id: ytSearchResultsList
        anchors.fill: parent
        model: exampleModel
        header: Row {
            width: parent.width
            spacing: 1
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

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
                }

                // is called when user presses the Return key
                function searchEntered() {
                    busy.running = true
                    busy.visible = true
                    exampleModel.clear()
                    searchField.acceptedInput = text
                    _ytdl.getYtSearchResults(acceptedInput)
                    searchField.focus = false
                    // Search History adding
                    //DB.addSearchHistory(text)
                    //mainWindow.firstPage.addSearchHistory(text)
                }
            }
        }
        delegate: YTSearchResultItem {
            title: titleYT
            thumbnail: thumbnailYT
            channelName: channelNameYT
            channelUrl: channelUrlYT
            videoId: videoIdYT
            videoUrl: videoUrlYT
            duration: durationYT
            uploadDate: uploadDateYT
        }
    }

    Connections {
        target: _ytdl
        onYtSearchResultsChanged: {
            if (ytSearchResultsJson != "") {  // Don't load empty stuff
                var JsonObject = JSON.parse(ytSearchResultsJson)
                for (var i = 0; i < JsonObject.entries.length; i++){
                    console.debug(JsonObject.entries[i]);
                    var yt720p
                    for (var j = 0; j < JsonObject.entries[i].formats.length; j++) {
                        console.debug("===DEBUG==== JsonObject.entries[i].formats[j].format_note:" + JsonObject.entries[i].formats[j].format_note)
                        if (JsonObject.entries[i].formats[j].format_note == "720p") {
                            yt720p = JsonObject.entries[i].formats[j].url
                        }
                    }
                    exampleModel.append(
                                {
                                    "titleYT": JsonObject.entries[i].title,
                                    "thumbnailYT": JsonObject.entries[i].thumbnail,
                                    "channelNameYT": JsonObject.entries[i].channel_id,
                                    "channelUrlYT": JsonObject.entries[i].uploader_url,
                                    "videoIdYT": JsonObject.entries[i].id,
                                    "videoUrlYT": yt720p,
                                    "durationYT": JsonObject.entries[i].duration.toString(),
                                    "uploadDateYT": JsonObject.entries[i].upload_date.toString()
                                }
                                )
                }

            }
            else {
                // Fail silently
                busy.running = false
                busy.visible = false
            }
        }
    }

}
