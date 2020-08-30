import QtQuick 2.0
import Sailfish.Silica 1.0
import "helper/db.js" as DB

Dialog {
    id: settingsPage

    allowedOrientations: Orientation.All

    acceptDestinationAction: PageStackAction.Pop

//    property string uAgentTitle : mainWindow.userAgentName
//    property string uAgent: mainWindow.userAgent
//    property string searchEngineTitle: mainWindow.searchEngineName
//    property string searchEngineUri: mainWindow.searchEngine


    // Easy fix only for when http:// or https:// is missing
//    function fixUrl(nonFixedUrl) {
//        var valid = nonFixedUrl
//        if (valid.indexOf(":")<0) {
//                return "http://"+valid;
//        } else return valid
//    }

    RemorsePopup { id: remorse }

    function loadDefaults() {
        loadSubtitlesSwitch.checked = true ;
        subtitleSizeCombo.currentIndex = 1;
        boldSubtitlesSwitch.checked = false ;
        colorIndicator.color = Theme.highlightColor
        directYoutubeSwitch.checked = true;
        openDialogCombo.currentIndex = 0;
        liveViewSwitch.checked = true;
        solidSubtitlesSwitch.checked = false;
        ytDefaultQualCombo.currentIndex = 0;
        clearWebViewOnExitSwitch.checked = false;
        alwaysYtdlSwitch.checked = false;
        showMinPlayerSwitch.checked = false;
    }

    function clearHistory() {
        remorse.execute(qsTr("Clear History"), mainWindow._clearHistory() )
    }

    function saveSettings() {
        DB.addSetting("enableSubtitles", loadSubtitlesSwitch.checked.toString());
        DB.addSetting("subtitlesSize", subtitleSizeCombo.subtitleSize.toString());
        DB.addSetting("boldSubtitles", boldSubtitlesSwitch.checked.toString());
        DB.addSetting("subtitlesColor", colorIndicator.color);
        DB.addSetting("youtubeDirect", directYoutubeSwitch.checked.toString());
        //console.log("[SettingsPage.qml] openDialogCombo.dType:" + openDialogCombo.dType.toString());
        DB.addSetting("openDialogType", openDialogCombo.dType.toString());
        DB.addSetting("liveView", liveViewSwitch.checked.toString());
        DB.addSetting("subtitleSolid", solidSubtitlesSwitch.checked.toString());
        DB.addSetting("ytDefaultQual", ytDefaultQualCombo.qual.toString());
        DB.addSetting("onlyMusicState", onlyMusicCombo.onlyMusicState.toString());
        DB.addSetting("clearWebViewOnExit", clearWebViewOnExitSwitch.checked.toString());
        DB.addSetting("alwaysYtdl", alwaysYtdlSwitch.checked.toString());
        DB.addSetting("showMinPlayer", showMinPlayerSwitch.checked.toString());
        DB.getSettings();
    }

//    // TODO : Maybe it can be made as convenient as AddBookmark !?
//    function enterPress() {
//        if (hp.focus == true) { hp.text = fixUrl(hp.text);hp.focus = false; }
//        else if (searchEngine.focus == true) { searchEngine.text = fixUrl(searchEngine.text); searchEngine.focus = false; }
//    }

//    function clearCache() {
//        remorse.execute(qsTr("Clear cache"), function() { mainWindow.clearCache(); } )
//    }

//    function clearCookies() {
//        remorse.execute(qsTr("Clear Cookies and restart"), function() { mainWindow.clearCookies(); } )
//    }

//    function clearHistory() {
//        remorse.execute(qsTr("Clear History"), function() { DB.clearTable("history"); } )
//    }


    onAccepted: saveSettings();

//    Keys.onReturnPressed: enterPress();
//    Keys.onEnterPressed: enterPress();

//    RemorsePopup { id: remorse }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: col.height + head.height

        DialogHeader {
            id: head
            acceptText: qsTr("Save Settings")
        }

        PullDownMenu {
//            MenuItem {
//                text: qsTr("Add default bookmarks")
//                onClicked: mainWindow.addDefaultBookmarks();
//            }
//            MenuItem {
//                text: qsTr("Clear Cache")
//                onClicked: clearCache();
//            }
//            MenuItem {
//                text: qsTr("Clear Cookies")
//                onClicked: clearCookies();
//            }
//            MenuItem {
//                text: qsTr("Clear History")
//                onClicked: clearHistory();
//            }
            MenuItem {
                text: qsTr("Load Defaults")
                onClicked: loadDefaults();
            }
        }

//        PushUpMenu {
//            MenuItem {
//                text: qsTr("Goto top")
//                onClicked: flick.scrollToTop();
//            }
//        }

        Column {
            id: col
            width: parent.width
            anchors.top: head.bottom
            spacing: 15

//            SectionHeader {
//                text: qsTr("Appearance")
//            }
//            ComboBox {
//                id: defaultFontCombo
//                anchors.horizontalCenter: parent.horizontalCenter
//                label: qsTr("Default Font Size")
//                currentIndex: 34 - parseInt(mainWindow.defaultFontSize)
//                menu: ContextMenu {
//                    MenuItem { text: "34"}
//                    MenuItem { text: "33"}
//                    MenuItem { text: "32"}
//                    MenuItem { text: "31"}
//                    MenuItem { text: "30"}
//                    MenuItem { text: "29"}
//                    MenuItem { text: "28"}
//                    MenuItem { text: "27"}
//                    MenuItem { text: "26"}
//                    MenuItem { text: "25"}
//                    MenuItem { text: "24"}
//                    MenuItem { text: "23"}
//                    MenuItem { text: "22"}
//                    MenuItem { text: "21"}
//                    MenuItem { text: "20"}
//                    MenuItem { text: "19"}
//                    MenuItem { text: "18"}
//                    MenuItem { text: "17"}
//                    MenuItem { text: "16"}
//                    MenuItem { text: "15"}
//                    MenuItem { text: "14"}
//                    MenuItem { text: "13"}
//                    MenuItem { text: "12"}
//                    MenuItem { text: "11"}
//                    MenuItem { text: "10"}
//                    MenuItem { text: "9" }
//                }
//            }
//            ComboBox {
//                id: defaultFixedFontCombo
//                anchors.horizontalCenter: parent.horizontalCenter
//                label: qsTr("Default Fixed Font Size")
//                currentIndex: 34 - parseInt(mainWindow.defaultFixedFontSize)
//                menu: ContextMenu {
//                    MenuItem { text: "34" }
//                    MenuItem { text: "33" }
//                    MenuItem { text: "32" }
//                    MenuItem { text: "31" }
//                    MenuItem { text: "30" }
//                    MenuItem { text: "29" }
//                    MenuItem { text: "28" }
//                    MenuItem { text: "27" }
//                    MenuItem { text: "26" }
//                    MenuItem { text: "25" }
//                    MenuItem { text: "24" }
//                    MenuItem { text: "23" }
//                    MenuItem { text: "22" }
//                    MenuItem { text: "21" }
//                    MenuItem { text: "20" }
//                    MenuItem { text: "19" }
//                    MenuItem { text: "18" }
//                    MenuItem { text: "17" }
//                    MenuItem { text: "16" }
//                    MenuItem { text: "15" }
//                    MenuItem { text: "14" }
//                    MenuItem { text: "13" }
//                    MenuItem { text: "12" }
//                    MenuItem { text: "11" }
//                    MenuItem { text: "10" }
//                    MenuItem { text: "9" }
//                }
//            }
//            ComboBox {
//                id: minimumFontCombo
//                anchors.horizontalCenter: parent.horizontalCenter
//                label: qsTr("Minimum Font Size")
//                currentIndex: 34 - parseInt(mainWindow.minimumFontSize)
//                menu: ContextMenu {
//                    MenuItem { text: "34" }
//                    MenuItem { text: "33" }
//                    MenuItem { text: "32" }
//                    MenuItem { text: "31" }
//                    MenuItem { text: "30" }
//                    MenuItem { text: "29" }
//                    MenuItem { text: "28" }
//                    MenuItem { text: "27" }
//                    MenuItem { text: "26" }
//                    MenuItem { text: "25" }
//                    MenuItem { text: "24" }
//                    MenuItem { text: "23" }
//                    MenuItem { text: "22" }
//                    MenuItem { text: "21" }
//                    MenuItem { text: "20" }
//                    MenuItem { text: "19" }
//                    MenuItem { text: "18" }
//                    MenuItem { text: "17" }
//                    MenuItem { text: "16" }
//                    MenuItem { text: "15" }
//                    MenuItem { text: "14" }
//                    MenuItem { text: "13" }
//                    MenuItem { text: "12" }
//                    MenuItem { text: "11" }
//                    MenuItem { text: "10" }
//                    MenuItem { text: "9" }
//                }
//            }

            SectionHeader {
                text: qsTr("General")
            }
//            Row {
//                anchors.horizontalCenter: parent.horizontalCenter
//                spacing: 25
//                Label {
//                    text: qsTr("Homepage: ")
//                }
//                TextField {
//                    id: hp
//                    text: mainWindow.homepage  // FIX: on new Window loading siteURL != homepage set in settings so add a new var homepage in mainWindow
//                    inputMethodHints: Qt.ImhUrlCharactersOnly
//                    onFocusChanged: if (focus == true) selectAll();
//                }
//            }
//            ValueButton {
//                anchors.horizontalCenter: parent.horizontalCenter
//                id: searchEngineCombo
//                label: qsTr("Search Engine:")
//                value: searchEngineTitle
//                onClicked: pageStack.push(Qt.resolvedUrl("SearchEngineDialog.qml"), {dataContainer: settingsPage});
//            }
//            Row {
//                id: customSearchEngine
//                visible: searchEngineCombo.value === qsTr("Custom")
//                // TODO: Make a ValueButton out of it and add a List with predefined search engines
//                anchors.horizontalCenter: parent.horizontalCenter
//                spacing: 10
//                Label {
//                    id: searchlbl
//                    text: qsTr("Engine Url: ")
//                }
//                TextField {
//                    id: searchEngine
//                    text: searchEngineUri
//                    inputMethodHints: Qt.ImhUrlCharactersOnly
//                    placeholderText: "%s for searchterm"
//                    width: hp.width
//                    onFocusChanged: if (focus == true) selectAll();
//                }
//            }
            TextSwitch {
                id: loadSubtitlesSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Load Subtitles")
                checked: mainWindow.firstPage.enableSubtitles
            }

            TextSwitch {
                id: boldSubtitlesSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Bold Subtitle Font")
                checked: mainWindow.firstPage.boldSubtitles
                visible: loadSubtitlesSwitch.checked
            }

            ComboBox {
                id: subtitleSizeCombo
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("Subtitle Font Size")
                visible: loadSubtitlesSwitch.checked
                property string subtitleSize: mainWindow.firstPage.subtitlesSize
                currentIndex: {
                    // Current Option
                    if (mainWindow.firstPage.subtitleSize === Theme.fontSizeSmall) return 0;
                    else if (mainWindow.firstPage.subtitlesSize === Theme.fontSizeMedium) return 1;
                    else if (mainWindow.firstPage.subtitlesSize === Theme.fontSizeLarge) return 2;
                    else if (mainWindow.firstPage.subtitlesSize === Theme.fontSizeExtraLarge) return 3;
                }
                menu: ContextMenu {
                    MenuItem { text: qsTr("Small") }
                    MenuItem { text: qsTr("Medium") }
                    MenuItem { text: qsTr("Large") }
                    MenuItem { text: qsTr("Extra Large") }
                }
                onCurrentIndexChanged: {
                    if (currentIndex == 0) subtitleSize = "small"
                    else if (currentIndex == 1) subtitleSize = "medium"
                    else if (currentIndex == 2) subtitleSize = "large"
                    else if (currentIndex == 3) subtitleSize = "extralarge"
                }
            }

            BackgroundItem {
                id: colorPickerButton
                visible: loadSubtitlesSwitch.checked
                Row {
                    x: Theme.paddingLarge
                    height: parent.height
                    spacing: Theme.paddingMedium
                    Rectangle {
                        id: colorIndicator

                        width: height
                        height: parent.height
                        color: mainWindow.firstPage.subtitlesColor
                    }
                    Label {
                        text: qsTr("Subtitle Color")
                        color: colorPickerButton.down ? Theme.highlightColor : Theme.primaryColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                onClicked: {
                    var allowedColors = ["#FFFFFF","#0000C0","#00FFFF","#00FF00", "#FF0000", "#FF8000", "#FFFF00", "#FFFFC0", "#000000", "#C0FFC0", "#C0C0FF", "#FFC0C0", Theme.primaryColor, Theme.secondaryColor, Theme.highlightColor]
                    var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog", {colors: allowedColors})
                    dialog.accepted.connect(function() {
                        colorIndicator.color = dialog.color
                    })
                }
            }

            TextSwitch {
                id: solidSubtitlesSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Use solid subtitletext background")
                checked: mainWindow.firstPage.subtitleSolid
                visible: loadSubtitlesSwitch.checked
            }

            TextSwitch {
                id: showMinPlayerSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Show mini player when swiping back from main player")
                checked: mainWindow.firstPage.showMinPlayer
            }

            TextSwitch {
                id: directYoutubeSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Use direct youtube url"
                checked: mainWindow.firstPage.youtubeDirect
                visible: false // Disabled YTAPI
            }

            ComboBox {
                id: openDialogCombo
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("Browse File Dialog")
                visible: loadSubtitlesSwitch.checked
                property string dType: mainWindow.firstPage.openDialogType
                currentIndex: {
                    // Current Option
                    if (mainWindow.firstPage.openDialogType === "adv") return 0;
                    else if (mainWindow.firstPage.openDialogType === "simple") return 0;
                    else if (mainWindow.firstPage.openDialogType === "gallery") return 1;
                }

                menu: ContextMenu {
                    MenuItem { text: qsTr("Filemanager") }
                    MenuItem { text: qsTr("Videogallery") }
                }
                onCurrentIndexChanged: {
                    if (currentIndex == 0) dType = "adv"
                    else if (currentIndex == 0) dType = "simple"
                    else if (currentIndex == 1) dType = "gallery"
                }
            }

            ComboBox {
                id: ytDefaultQualCombo
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("Default Youtube Quality")
                visible: loadSubtitlesSwitch.checked
                property string qual: mainWindow.firstPage.ytQualWanted
                currentIndex: {
                    // Current Option
                    if (mainWindow.firstPage.ytQualWanted === "720p") return 0;
                    else if (mainWindow.firstPage.ytQualWanted  === "480p") return 1;
                    else if (mainWindow.firstPage.ytQualWanted === "360p") return 2;
                    else if (mainWindow.firstPage.ytQualWanted === "240p") return 3;
                }

                menu: ContextMenu {
                    MenuItem { text: "720p" }
                    MenuItem { text: "480p" }
                    MenuItem { text: "360p" }
                    MenuItem { text: "240p" }
                }
                onCurrentIndexChanged: {
                    if (currentIndex == 0) qual = "720p"
                    else if (currentIndex == 1) qual = "480p"
                    else if (currentIndex == 2) qual = "360p"
                    else if (currentIndex == 3) qual = "240p"
                }
            }

            TextSwitch {
                id: liveViewSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Use live preview when minimized")
                checked: mainWindow.firstPage.liveView
            }

            ComboBox {
                id: onlyMusicCombo
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("Music Only Indicator")
                visible: loadSubtitlesSwitch.checked
                property string onlyMusicState: mainWindow.firstPage.onlyMusicState
                currentIndex: {
                    // Current Option
                    if (mainWindow.firstPage.onlyMusicState === "default") return 0;
                    else if (mainWindow.firstPage.onlyMusicState  === "mc") return 1;
                    else if (mainWindow.firstPage.ytQualWanted === "eq") return 2;
                }

                menu: ContextMenu {
                    MenuItem { text: qsTr("Default (Sound Icon)") }
                    MenuItem { text: qsTr("MC (animated Music Cassette)") }
                    MenuItem { text: qsTr("EQ (animated Equalizer)") }
                }
                onCurrentIndexChanged: {
                    if (currentIndex == 0) onlyMusicState = "default"
                    else if (currentIndex == 1) onlyMusicState = "mc"
                    else if (currentIndex == 2) onlyMusicState = "eq"
                }
            }

            TextSwitch {
                id: clearWebViewOnExitSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Clear webview data on exit")
                checked: mainWindow.clearWebViewOnExit
            }

            BackgroundItem {
                id: clearHistoryButton
                Label {
                    text: qsTr("Clear History")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    color: clearHistoryButton.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: clearHistory();
            }

            TextSwitch {
                id: alwaysYtdlSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Try to load all youtube videos with ytdl")
                checked: mainWindow.firstPage.alwaysYtdl
            }

            BackgroundItem {
                id: updateYtdlButton
                Label {
                    text: qsTr("Update Youtube-Dl")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    color: updateYtdlButton.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: { mainWindow.firstPage.updateYtdl(); pageStack.pop(); }
            }

//            SectionHeader {
//                text: "Advanced"
//            }
//            ValueButton {
//                anchors.horizontalCenter: parent.horizontalCenter
//                id: userAgentCombo
//                label: qsTr("User Agent:")
//                value: uAgentTitle
//                onClicked: pageStack.push(Qt.resolvedUrl("UserAgentDialog.qml"), {dataContainer: settingsPage});
//            }
//            TextField {
//                id: agentString
//                anchors.horizontalCenter: parent.horizontalCenter
//                readOnly: true
//                width: parent.width - 20
//                text: uAgent
//            }
//            TextSwitch {
//                id: dnsPrefetchSwitch
//                anchors.horizontalCenter: parent.horizontalCenter
//                text: "DNS Prefetch"
//                checked: mainWindow.dnsPrefetch
//            }
//            TextSwitch {
//                id: offlineWebApplicationCacheSwitch
//                anchors.horizontalCenter: parent.horizontalCenter
//                text: "Offline Web Application Cache"
//                checked: mainWindow.offlineWebApplicationCache
//            }

        }
        VerticalScrollDecorator {
            flickable: flick
        }
    }

}

