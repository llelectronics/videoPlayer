import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: rootItem

    property variant wrapMode
    property variant horizontalAlignment
    property variant verticalAlignment
    property variant pixelSize
    property variant bold
    property variant color
    property bool isSolid: false


    // Functions ///////////////////////////////////////////////////

    function getSubtitles(url) {
        if (url !== "") subsGetter.sendMessage(url);
        else subsGetter.sendMessage(streamUrl);
    }

    function setSubtitles(subtitles) {
        currentVideoSub = subtitles;
        //console.debug("[videoPlayer.qml] subtitles: " + currentVideoSub)
    }

    WorkerScript {
        id: subsGetter

        source: "getsubtitles.js"
        onMessage: {
            setSubtitles(messageObject);
            //console.debug("[videoPlayer.qml] subtitleMessageObject: " + messageObject);
        }
    }

    function checkSubtitles() {
        subsChecker.sendMessage({"position": videoPoster.position, "subtitles": currentVideoSub})
        //console.debug("[videoPlayer.qml] checkSubtitles activated with: " + currentVideoSub)
    }

    WorkerScript {
        id: subsChecker

        source: "checksubtitles.js"
        onMessage: {
            if (!isSolid) subtitlesText.text = messageObject
            else subtitlesTextArea.text = messageObject
            //console.debug("[videoPlayer.qml] subsChecker MessageObject: " + messageObject);
        }
    }

    function contrastingColor(color)
    {
        var rgb = getRGB(color);
        console.debug("[SubtitlesItem.qml] getrgb:" + rgb)
        if (!rgb) return null;
        return (0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]) > 180 ? "black" : "white";
    }
    function getRGB(b) {
        var a;
        if (b && b.constructor == Array && b.length == 3) return b;
        if (a = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(b)) return [parseInt(a[1]), parseInt(a[2]), parseInt(a[3])];
        if (a = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(b)) return [parseFloat(a[1]) * 2.55, parseFloat(a[2]) * 2.55, parseFloat(a[3]) * 2.55];
        if (a = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(b)) return [parseInt(a[1], 16), parseInt(a[2], 16), parseInt(a[3],
                                                                                                                                      16)];
        if (a = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(b)) return [parseInt(a[1] + a[1], 16), parseInt(a[2] + a[2], 16), parseInt(a[3] + a[3], 16)];
    }

    ///// End of Functions ////////////////////////////////////////////

    Label {
        id: subtitlesText

        z: 100
        anchors.fill: parent
        wrapMode: rootItem.wrapMode
        horizontalAlignment: rootItem.horizontalAlignment
        verticalAlignment: rootItem.verticalAlignment
        font.pixelSize: rootItem.pixelSize
        font.bold: rootItem.bold
        color: rootItem.color
        visible: parent.visible && !isSolid
        onTextChanged: {
            //console.debug("[videoPlayer.qml] Subtitletext: " + text)
        }
        style: Text.Outline
        styleColor: contrastingColor(color)
    }

    TextEdit {
        id: subtitlesTextArea

        z: 100
        anchors.fill: parent
        wrapMode: rootItem.wrapMode
        horizontalAlignment: rootItem.horizontalAlignment
        verticalAlignment: rootItem.verticalAlignment
        font.pixelSize: rootItem.pixelSize
        font.bold: rootItem.bold
        color: rootItem.color
        textFormat: Text.AutoText
        selectedTextColor: rootItem.color
        selectionColor: contrastingColor(color)
        visible: parent.visible && isSolid
        onTextChanged: {
            //console.debug("[videoPlayer.qml] Subtitletext: " + text)
            selectAll();
        }
    }
}
