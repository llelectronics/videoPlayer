// Glorious hack to fix wrong device Pixel Ratio reported by Webview (I hope Jolla will fix this soon)
if (screen.width <= 540) document.querySelector("meta[name=viewport]").setAttribute('content', 'width=device-width/1.5, initial-scale='+(1.5));
else if (screen.width > 540 && screen.width <= 768) document.querySelector("meta[name=viewport]").setAttribute('content', 'width=device-width/2.0, initial-scale='+(2.0));
else if (screen.width > 768) document.querySelector("meta[name=viewport]").setAttribute('content', 'width=device-width/3.0, initial-scale='+(3.0));
// Not sure if this will work on all resolutions
// Jolla devicePixelRatio: 1.5
// Nexus 4 devicePixelRatio: 2.0
// Nexus 5 devicePixelRatio: 3.0

// Long Touch detection
var hold;
var longpressDetected = false;
var currentTouch = null;

function findTag(element, tagN) {
    var currelement = element

    while(currelement) {
        if(currelement.tagName === "BODY")
            return null;

        if(currelement.tagName === tagN)
            break;

        currelement = currelement.parentNode;
    }

    return currelement;
}

function longPressed(x, y, element) {
    longpressDetected = true;
    //var element = document.elementFromPoint(x, y);

    // FIXME: should travel nodes to find links
    var data = new Object({'type': 'longpress', 'pageX': x, 'pageY': y})
    data.href = 'CANT FIND LINK'
    var anchors = findTag(element,"A");
    if (anchors) {
        data.href = anchors.href //getAttribute('href'); // We always want the absolute link
    }

    node = element.cloneNode(true);
    // filter out script nodes
    var scripts = node.getElementsByTagName('script');
    while (scripts.length > 0) {
        var scriptNode = scripts[0];
        if (scriptNode.parentNode) {
            scriptNode.parentNode.removeChild(scriptNode);
        }
    }
    data.html = node.outerHTML;
    data.nodeName = node.nodeName.toLowerCase();
    // FIXME: extract the text and images in the order they appear in the block,
    // so that this order is respected when the data is pushed to the clipboard.
    data.text = node.textContent;

    navigator.qt.postMessage( JSON.stringify(data) );
}

document.addEventListener('touchstart', (function(event) {
    if (event.touches.length > 1) {
        event.preventDefault();
        return;
    }
    else if (event.touches.length == 1) {
        currentTouch = event.touches[0];
        hold = setTimeout(longPressed, 800, currentTouch.clientX, currentTouch.clientY, event.target);
    }
}), true);

document.addEventListener('touchend', (function(event) {
    if (longpressDetected) {
        longpressDetected = false
        event.preventDefault();
    }
    currentTouch = null;
    clearTimeout(hold);
}), true);

function distance(touch1, touch2) {
    return Math.sqrt(Math.pow(touch2.clientX - touch1.clientX, 2) +
                     Math.pow(touch2.clientY - touch1.clientY, 2));
}

document.addEventListener('touchmove', (function(event) {
    if ((event.changedTouches.length > 1) || (distance(event.changedTouches[0], currentTouch) > 3)) {
        clearTimeout(hold);
        currentTouch = null;
    }
}), true);
