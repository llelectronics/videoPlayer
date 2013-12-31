function checkYoutube(url) {
    // Yeah I hate RegEx. Thx user2200660 for this nice youtube regex ;)
    //if (url.match('/?.*(?:youtu.be\\/|v\\/|u/\\w/|embed\\/|watch\\?.*&?v=)')) {
    // Use more advanced regex to detect youtube video urls
    if (url.match(/https?:\/\/(?:[0-9A-Z-]+\.)?(?:youtu\.be\/|youtube\.com(?:\/embed\/|\/v\/|\/watch\?v=|\/ytscreeningroom\?v=|\/feeds\/api\/videos\/|\/user\S*[^\w\-\s]|\S*[^\w\-\s]))([\w\-]{11})[?=&+%\w-]*/ig)) {
        console.debug("Youtube URL detected");
        return true;
    }
    else {
        return false;
    }
} 

function getYoutubeVid(url) {
    var youtube_id;
    if (url.match('embed')) { youtube_id = url.split(/embed\//)[1].split('"')[0]; }
    else { youtube_id = url.split(/v\/|v=|youtu\.be\//)[1].split(/[?&]/)[0]; }
    console.debug("Youtube ID: " + youtube_id);
    var ytUrl = getYoutubeStream(youtube_id);
    //if (ytUrl !== "") return ytUrl;  // XMLHttpRequest does not know synchronus in QML so I need to restructe everything if I directly want to use Youtubes server
    return("http://ytapi.com/?vid=" + youtube_id + "&format=direct");
}


// This would be a proper way to get the youtube video stream url
function getYoutubeStream(youtube_id) {

    var doc = new XMLHttpRequest();

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {

            var videoInfo = doc.responseText;

            var videoInfoSplit = videoInfo.split("&");
            var streams;
            for (var i = 0; i < videoInfo.length; i++) {
                var paramPair = videoInfoSplit[i].split("=");
                if (paramPair[0] === "url_encoded_fmt_stream_map") {
                    streams = decodeURIComponent(paramPair[1]);
                    break;
                }
            }

            if (!streams) {
                var msg = "YouTube videoInfo parsing: url_encoded_fmt_stream_map not found";
                console.debug(msg);
                return;
            }
            var streamsSplit = streams.split("&");

            // some lines contain two value pairs separated by comma
            var newSplit = [];
            for (var i = 0; i < streamsSplit.length; i++) {
                var secondSplit = streamsSplit[i].split(",");
                newSplit.push.apply(newSplit, secondSplit);
            }
            streamsSplit = newSplit;

            var url, sig, itag;
            var found = false;
            for (var i = 0; i < streamsSplit.length; i++) {
                var paramPair = streamsSplit[i].split("=");
                if (paramPair[0] === "url") {
                    url = decodeURIComponent(paramPair[1]);
                } else if (paramPair[0] === "sig") {
                    sig = paramPair[1]; // do not decode, as we would have to encode it later (although decoding/encoding has currently no effect for the signature)
                } else if (paramPair[0] === "itag") {
                    itag = paramPair[1];
                }
                if ((i + 1) % 6 === 0 && itag === "18") { // 6 parameters per video; itag 18 is "MP4 360p", see http://userscripts.org/scripts/review/25105
                    found = true;
                    url += "&signature=" + sig;
                    break;
                }
            }

            if (found) {
                console.debug("video direct URL found: " + url);
                return url;

            } else {
                var msg = "Couldn't find video in MP4 360p";
                console.debug(msg);
                return;
            }

        }



    }

    doc.open("GET", "http://www.youtube.com/get_video_info?video_id=" + youtube_id);
    doc.send();
}
