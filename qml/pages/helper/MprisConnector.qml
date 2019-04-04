import QtQuick 2.0
import org.nemomobile.mpris 1.0

MprisPlayer {
    id: mprisPlayer

    serviceName: "llsVplayer"

    property string title

    function hide() {
        canControl = false;
        title = "";
    }

    function show() {
        canControl = true;
    }

    onTitleChanged: {
        if (title != "") {
            console.debug("Title changed to: " + title)
            var metadata = mprisPlayer.metadata
            metadata[Mpris.metadataToString(Mpris.Title)] = title
            mprisPlayer.metadata = metadata
        }
    }

    // Mpris2 Root Interface
    identity: "LLs Video Player"

    // Mpris2 Player Interface
    canControl: true

    canGoNext: true
    canGoPrevious: true
    canPause: true
    canPlay: true
    canSeek: true

    onPlaybackStatusChanged: {
        mprisPlayer.canGoNext = mainWindow.modelPlaylist.isNext() && mainWindow.firstPage.isPlaylist
        mprisPlayer.canGoPrevious = mainWindow.modelPlaylist.isPrev() && mainWindow.firstPage.isPlaylist
    }

    loopStatus: Mpris.None
    shuffle: false
    volume: 1
}
