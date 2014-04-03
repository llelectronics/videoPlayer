WorkerScript.onMessage = function(url) {
    var subtitles = [];
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            try {
                // This implementation below only works with single line srts
//                var contents = doc.responseText.replace(/\r/g, "").slice(1);
//                var lines = contents.split(/\n+\d+\n|,\d{3}\n|\s-->\s/);
//                var i = 0;
//                while (i < (lines.length - 3)) {
//                    var sub = {};
//                    sub["start"] = getSubTime(lines[i]);
//                    i++;
//                    sub["end"] = getSubTime(lines[i] + ",500");
//                    i++;
//                    sub["text"] = lines[i];
//                    i++;
//                    subtitles.push(sub);

                // This should work with multi line srts but might contain sme bugs still

                var srt;
                srt = doc.responseText.replace(/\r\n|\r|\n/g, '\n')

                srt = strip(srt);
                var srt_ = srt.split('\n\n');
                var s, st,n;
                for(s in srt_) {
                    var sub = {};
                    st = srt_[s].split('\n');
                    if(st.length >=2) {
                        n = st[0];
                        sub["start"] = getSubTime(strip(st[1].split(' --> ')[0]));
                        sub["end"] = getSubTime(strip(st[1].split(' --> ')[1]));
                        sub["text"] = st[2];
                        if(st.length > 2) {
                            for(var j=3; j<st.length;j++)
                                sub["text"] += '\n'+st[j];
                        }
                        console.debug("[getsubtitles] sub[text]: " + sub["text"]);
//                        is = toSeconds(i);
//                        os = toSeconds(o);
                        //subtitles[is] = {i:i, o: o, t: t};
                        subtitles.push(sub)
                    }
                }
                WorkerScript.sendMessage(subtitles);
            }
            catch(err) {
                console.log("[getsubtitles] Cannot retrieve subtitles. Error message: " + err);
                WorkerScript.sendMessage([]);
            }
        }
    }
    doc.open("GET", url.slice(0, url.lastIndexOf(".")) + ".srt");
    doc.send();
}

function strip(string) {
    return string.replace(/^\s+|\s+$/g, '');
}

function getSubTime(time) {
    var hms = time.split(":");
    //console.debug("[getsubtitles] hms[0]:" + hms[0] + " hms[1]:" + hms[1] + " hms[2]" + hms[2])
    var hours = hms[0] * 3600000;
    var mins = hms[1] * 60000;
    var sms = hms[2].split(",");
    var secs = sms[0] * 1000;
    var msecs = parseInt(sms[1]);
    return hours + mins + secs + msecs;
}
