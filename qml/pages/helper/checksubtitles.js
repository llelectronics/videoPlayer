WorkerScript.onMessage = function(message) {
    var found = false;
    var i = 0;
    var sub;
    var text = "";
    while ((!found) && (i < message.subtitles.length)) {
        sub = message.subtitles[i];
        if ((message.position*1000 >= sub.start) && (message.position*1000 <= sub.end)) {
            text = sub.text;
            console.debug("[checksubtitles] text: " + text);
            found = true;
        }
        i++;
    }
    WorkerScript.sendMessage(text);
}
