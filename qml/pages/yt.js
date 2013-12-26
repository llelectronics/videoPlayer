function checkYoutube(url) {
        // Yeah I hate RegEx. Thx user2200660 for this nice youtube regex ;)
        if (url.match('/?.*(?:youtu.be\\/|v\\/|u/\\w/|embed\\/|watch\\?.*&?v=)')) {
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
  return("http://ytapi.com/?vid=" + youtube_id + "&format=direct");
}
