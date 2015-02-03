// Glorious hack to fix wrong device Pixel Ratio reported by Webview (I hope Jolla will fix this soon)
if (screen.width <= 540) document.querySelector("meta[name=viewport]").setAttribute('content', 'width=device-width/1.5, initial-scale='+(1.5));
else if (screen.width > 540 && screen.width <= 768) document.querySelector("meta[name=viewport]").setAttribute('content', 'width=device-width/2.0, initial-scale='+(2.0));
else if (screen.width > 768) document.querySelector("meta[name=viewport]").setAttribute('content', 'width=device-width/3.0, initial-scale='+(3.0));
// Not sure if this will work on all resolutions
// Jolla devicePixelRatio: 1.5
// Nexus 4 devicePixelRatio: 2.0
// Nexus 5 devicePixelRatio: 3.0
