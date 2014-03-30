var url720p;
var url480p;
var url360p;
var url240p;

function checkYoutube(url) {
    // Yeah I hate RegEx. Thx user2200660 for this nice youtube regex ;)
    //if (url.match('/?.*(?:youtu.be\\/|v\\/|u/\\w/|embed\\/|watch\\?.*&?v=)')) {
    // Use more advanced regex to detect youtube video urls
    if (url.match(/https?:\/\/(?:[0-9A-Z-]+\.)?(?:youtu\.be\/|youtube\.com(?:\/embed\/|\/v\/|\/watch\?v=|\/ytscreeningroom\?v=|\/feeds\/api\/videos\/|\/user\S*[^\w\-\s]|\S*[^\w\-\s]))([\w\-]{11})[?=&+%\w-]*/ig) || url.match(/ytapi.com/)) {
        console.debug("Youtube URL detected");
        return true;
    }
    else {
        return false;
    }
} 

function getYtID(url) {
    var youtube_id;
    if (url.match('embed')) { youtube_id = url.split(/embed\//)[1].split('"')[0]; }
    else if (url.match(/ytapi.com/)) { youtube_id = url.split(/vid=/)[1].split(/[?&]/)[0]; }
    else { youtube_id = url.split(/v\/|v=|youtu\.be\//)[1].split(/[?&]/)[0]; }
    console.debug("Youtube ID: " + youtube_id);
    return youtube_id;
}

function getYoutubeVid(url) {
    var youtube_id;
    youtube_id = getYtID(url);
    var ytUrl = getYoutubeStream(youtube_id);
    //if (ytUrl !== "") return ytUrl;  // XMLHttpRequest does not know synchronus in QML so I need to restructe everything if I directly want to use Youtubes server
    return("http://ytapi.com/?vid=" + youtube_id + "&format=direct");
}

function getYoutubeTitle(url) {
    var youtube_id;
    youtube_id = getYtID(url);
    var xhr = new XMLHttpRequest();
    xhr.open("GET","http://gdata.youtube.com/feeds/api/videos/" + youtube_id + "?v=2&alt=jsonc",true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                var jsonObject = eval('(' + xhr.responseText + ')');
                console.log("Youtube Title: " + jsonObject.data.title);
                firstPage.streamTitle = jsonObject.data.title;
//                for ( var index in jsonObject.data )
//                {
//                    console.log("Youtube Title: " + jsonObject.data.title);
//                    firstPage.streamTitle = jsonObject.data.title;
//                }
            } else {
                console.log("responseText", xhr.responseText);
            }
        }
    }
    xhr.send();
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
                try {
                    var paramPair = videoInfoSplit[i].split("=");
                } catch(e) {
                    console.debug("[yt.js]: " + e)
                }
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
            var resolutionFormat;
            for (var i = 0; i < streamsSplit.length; i++) {
                var paramPair = streamsSplit[i].split("=");
                if (paramPair[0] === "url") {
                    url = decodeURIComponent(paramPair[1]);
                } else if (paramPair[0] === "sig") {
                    sig = paramPair[1]; // do not decode, as we would have to encode it later (although decoding/encoding has currently no effect for the signature)
                } else if (paramPair[0] === "itag") {
                    itag = paramPair[1];
                }
                //***********************************************//
                //     List of video formats as of 2012.12.10    //
                // fmt=17   144p        vq=?           ?    vorbis   //
                // fmt=36   240p        vq=small/tiny  ?    vorbis   //
                // fmt=5    240p        vq=small/tiny  flv  mp3      //
                // fmt=18   360p        vq=medium      mp4  aac      //
                // fmt=34   360p        vq=medium      flv  aac      //
                // fmt=43   360p        vq=medium      vp8  vorbis   //
                // fmt=35   480p        vq=large       flv  aac      //
                // fmt=44   480p        vq=large       vp8  vorbis   //
                // fmt=22   720p        vq=hd720       mp4  aac      //
                // fmt=45   720p        vq=hd720       vp8  vorbis   //
                // fmt=37  1080p        vq=hd1080      mp4  aac      //
                // fmt=46  1080p        vq=hd1080      vp8  vorbis   //
                // fmt=38  1536p        vq=highres     mp4  aac      //
                //***********************************************//

                // Try to get 720p HD video stream first
                if ((i + 1) % 6 === 0 && itag === "22") { // 6 parameters per video; itag 18 is "MP4 360p", see http://userscripts.org/scripts/review/25105
                    found = true;
                    resolutionFormat = "MP4 720p"
                    url += "&signature=" + sig;
                    url720p = url;
                    break;
                } else { url720p = "none" }
                // If above fails try to get 480p video stream
                if ((i + 1) % 6 === 0 && itag === "35") { // 6 parameters per video; itag 18 is "MP4 360p", see http://userscripts.org/scripts/review/25105
                    found = true;
                    resolutionFormat = "FLV 480p"
                    url += "&signature=" + sig;
                    url480p = url;
                    break;
                } else { url480p = "none" }
                // If above fails try to get 360p video stream
                if ((i + 1) % 6 === 0 && itag === "18") { // 6 parameters per video; itag 18 is "MP4 360p", see http://userscripts.org/scripts/review/25105
                    found = true;
                    resolutionFormat = "MP4 360p"
                    url += "&signature=" + sig;
                    url360p = url;
                    break;
                } else { url360p = "none" }
                // If above fails try to get 240p video stream
                if ((i + 1) % 6 === 0 && itag === "5") { // 6 parameters per video; itag 18 is "MP4 360p", see http://userscripts.org/scripts/review/25105
                    found = true;
                    resolutionFormat = "FLV 240p"
                    url += "&signature=" + sig;
                    url240p = url;
                    break;
                } else { url240p = "none" }
            }

            if (found) {
                console.debug("[yt.js]: Video in format " + resolutionFormat + " found with direct URL: " + url);
                return url;

            } else {
                var msg = "Couldn't find video either in MP4 720p, FLV 480p, MP4 360p and FLV 240p";
                console.debug(msg);
                return;
            }

        }



    }

    doc.open("GET", "http://www.youtube.com/get_video_info?video_id=" + youtube_id);
    doc.send();
}


// Damn it RegExp again :P
function getDownloadableTitleString(streamTitle) {
    if (streamTitle.match(/\//g)) streamTitle = streamTitle.replace(/\//g, "");
    if (streamTitle.match(/\?/g)) streamTitle = streamTitle.replace(/\?/g,'');
    if (streamTitle.match('!')) streamTitle = streamTitle.replace("!", "");
    if (streamTitle.match(/\*/g)) streamTitle = streamTitle.replace(/\*/g, "");
    if (streamTitle.match('`')) streamTitle = streamTitle.replace("`", "");
    if (streamTitle.match('~')) streamTitle = streamTitle.replace("~", "");
    if (streamTitle.match('@')) streamTitle = streamTitle.replace("@", "");
    if (streamTitle.match('#')) streamTitle = streamTitle.replace("#", "");
    if (streamTitle.match('$')) streamTitle = streamTitle.replace("$", "");
    if (streamTitle.match('%')) streamTitle = streamTitle.replace("%", "");
    if (streamTitle.match('^')) streamTitle = streamTitle.replace("^", "");
    if (streamTitle.match(/\\/g)) streamTitle = streamTitle.replace(/\\/g, "");
    if (streamTitle.match('|')) streamTitle = streamTitle.replace("|", "");
    if (streamTitle.match('<')) streamTitle = streamTitle.replace("<", "");
    if (streamTitle.match('>')) streamTitle = streamTitle.replace(">", "");
    if (streamTitle.match(';')) streamTitle = streamTitle.replace(";", "");
    if (streamTitle.match(':')) streamTitle = streamTitle.replace(":", "");
    if (streamTitle.match('\'')) streamTitle = streamTitle.replace("\'", "");
    if (streamTitle.match('\"')) streamTitle = streamTitle.replace("\"", "");
    if (streamTitle.match(/\[/g)) streamTitle = streamTitle.replace(/\[/g, "");
    if (streamTitle.match(/\]/g)) streamTitle = streamTitle.replace(/\]/g, "");
    if (streamTitle.match(/\{/g)) streamTitle = streamTitle.replace(/\{/g, "");
    if (streamTitle.match(/\}/g)) streamTitle = streamTitle.replace(/\}/g, "");
    return streamTitle;
}
