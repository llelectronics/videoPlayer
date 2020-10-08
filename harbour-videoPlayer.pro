# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-videoPlayer

QT += multimedia

CONFIG += sailfishapp

SOURCES += src/harbour-videoPlayer.cpp \
    src/DownloadManager.cpp \
    src/folderlistmodel/qquickfolderlistmodel.cpp \
    src/folderlistmodel/fileinfothread.cpp \
    src/playlist.cpp

OTHER_FILES += qml/harbour-videoPlayer.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/harbour-videoPlayer.spec \
    rpm/harbour-videoPlayer.yaml \
    harbour-videoPlayer.desktop \
    qml/pages/OpenURLPage.qml \
    qml/pages/helper/yt.js \
    qml/pages/helper/VideoPoster.qml \
    qml/pages/FileDetails.qml \
    qml/pages/helper/db.js \
    qml/pages/helper/qmldir \
    qml/pages/CreditsModel.qml \
    qml/pages/AboutPage.qml \
    qml/pages/DownloadManager.qml \
    qml/pages/BookmarksPage.qml \
    qml/pages/AddBookmark.qml \
    qml/pages/ytQualityChooser.qml \
    qml/pages/helper/getsubtitles.js \
    qml/pages/helper/checksubtitles.js \
    qml/pages/SettingsPage.qml \
    qml/pages/fileman/OpenDialog.qml \
    qml/pages/helper/userscript.js \
    qml/pages/videoPlayer.qml \
    qml/pages/helper/ItemButton.qml \
    qml/pages/helper/youtube-dl

HEADERS += \
    src/DownloadManager.hpp \
    src/fmhelper.hpp \
    src/folderlistmodel/qquickfolderlistmodel.h \
    src/folderlistmodel/fileproperty_p.h \
    src/folderlistmodel/fileinfothread_p.h \
    src/youtubedl-helper.hpp \
    src/playlist.h

DISTFILES += \
    qml/pages/HistoryPage.qml \
    qml/pages/YTSearchResultsPage.qml \
    qml/pages/helper/Jupii.qml \
    qml/pages/helper/SubtitlesItem.qml \
    qml/pages/PlaylistPage.qml \
    qml/pages/InfoBanner.qml \
    qml/pages/helper/PopOver.qml \
    qml/pages/fileman/qmldir \
    qml/pages/fileman/helper/fmComponents/CreateDirDialog.qml \
    qml/pages/fileman/helper/fmComponents/DirEntryDelegate.qml \
    qml/pages/fileman/helper/fmComponents/FileProperties.qml \
    qml/pages/fileman/helper/fmComponents/LetterSwitch.qml \
    qml/pages/fileman/helper/fmComponents/PermissionDialog.qml \
    qml/pages/fileman/helper/fmComponents/PlacesPage.qml \
    qml/pages/fileman/helper/fmComponents/RenameDialog.qml \
    qml/pages/helper/YTSearchResultItem.qml \
    translations/harbour-videoPlayer-de.ts \
    translations/harbour-videoPlayer-es.ts \
    translations/harbour-videoPlayer-pl.ts \
    translations/harbour-videoPlayer-ru.ts \
    translations/harbour-videoPlayer-sv.ts \
    translations/harbour-videoPlayer-zh_cn.ts \
    translations/harbour-videoPlayer-nl.ts \
    qml/pages/helper/Mplayer.qml \
    qml/pages/helper/SwipeArea.qml \
    qml/pages/helper/MinPlayerPanel.qml \
    qml/pages/helper/MprisConnector.qml \
    translations/harbour-videoPlayer.ts

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

TRANSLATIONS += translations/harbour-videoPlayer-de.ts \
                translations/harbour-videoPlayer-es.ts \
                translations/harbour-videoPlayer-sv.ts \
                translations/harbour-videoPlayer-zh_cn.ts \
                translations/harbour-videoPlayer-nl.ts

