WorkerScript.onMessage = function(url) {
  var exts = ['.srt', '.ssa', '.ass'];
  var parsers = [SrtParser, SsaParser, SsaParser];
  var e, cp, def = true, subtitles = [];
  var doc = new XMLHttpRequest();
  
  doc.onreadystatechange = function() {
    if (doc.readyState == XMLHttpRequest.DONE) {
      //console.debug('[getsubtitles] doc.status for ' + exts[cp] + ': ' + doc.status);
      if(doc.status == 200) {
        try {
          parsers[cp](doc, subtitles);
          WorkerScript.sendMessage(subtitles);
        }
        catch(err) {
          console.log("[getsubtitles] Cannot retrieve subtitles. Error message: " + err);
          WorkerScript.sendMessage([]);
        }
      }
      else if(!def && ++cp < parsers.length) getSub(doc, url, exts[cp]);
    }
  }

  e = url.slice(-4);
  cp = exts.indexOf(e);
  if(cp < 0) { cp = 0; def = false }
  getSub(doc, url, exts[cp]);
}

function getSub(doc, url, ext) {
  if(endsWith(url, ext)) {
    //console.debug("[getsubtitles.js] subtitle specified with url here: " + url);
    doc.open("GET", url);
  }
  else {
    //console.debug("[getsubtitles.js] No subtitle specified trying to load default")
    var i = url.lastIndexOf(".");
    if(i >= 0) doc.open("GET", url.slice(0, i) + ext);
    else doc.open("GET", url + ext)
  }
  doc.send();
}

function startsWith(txt, prefix) {
  return txt.substr(0, prefix.length) == prefix;
}

function endsWith(txt, suffix) {
  return txt.slice(-suffix.length) == suffix;
}

function SrtParser(doc, subtitles) {
  // This should work with multi line srts but might contain sme bugs still
  var srt_ = doc.responseText.replace(/\r\n?/g, '\n').trim().split(/\n{2,}/);
  var s, st, n, pp;
  for(s in srt_) {
    var sub = {};
    st = srt_[s].split('\n');
    if(st.length >=2) {
      n = st[0];
      pp = st[1].split(' --> ');
      sub["start"] = getSubTime(pp[0].trim());
      sub["end"] = getSubTime(pp[1].trim());
      sub["text"] = st[2];
      if(st.length > 3) {
        for(var j=3; j<st.length; j++)
          sub["text"] += '\n'+st[j];
      }
      //console.debug("[getsubtitles] sub[text]: " + sub["text"]);
      subtitles.push(sub)
    }
  }
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

function getSsaTime(time) {
  var hms = time.split(':');
  var hours = hms[0] * 3600000;
  var mins = hms[1] * 60000;
  var sms = parseFloat(hms[2])*1000|0;
  return hours + mins + sms;
}

function SsaParser(doc, subtitles) {
  var lines = doc.responseText.split(/[\r\n]+/);
  var a=0, si=1, ei=2, ti=9;
  var i, s, p, pp, j, n, tp;
  top:
  for(i in lines) {
    s = lines[i];
    switch (a) {
      case 0: if(s == '[Events]') a = 1; break;
      case 1: if(startsWith(s, 'Format:')) {
        a = 2;
        pp = s.replace(/^\w+:\s*/, '').split(/\s*,\s*/);
        si = pp.indexOf('Start');
        ei = pp.indexOf('End');
        ti = pp.indexOf('Text');
      } break;
      case 2: if(startsWith(s, 'Dialogue:')) {
        p = s.replace(/^\w+:\s*/, '');
        pp = p.split(',', ti);
        j=0; n=0;
        while((j = p.indexOf(',', j) + 1) > 0 && ++n < ti) {}
        tp = j ? p.slice(j) : '';
        var sub = {};
        sub['i'] = i;
        sub['start'] = getSsaTime(pp[si]);
        sub['end'] = getSsaTime(pp[ei]);
        sub['text'] = tp.replace(/\{.*?\}/g, '').replace(/\\N/g, '\n');
        //console.debug("[getsubtitles] sub[text]: " + sub["text"]);
        subtitles.push(sub);
      }
      else if(s[0] == '['){ break top }
    }
  }
  subtitles.sort(function(a, b) {
    if(a.start == b.start) return a.i - b.i;
    else return a.start - b.start });
}
