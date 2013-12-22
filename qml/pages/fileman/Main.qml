import Mer.Cutes 1.1
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0




DirView {
    id: mainPage
    property QtObject dataContainer

    CutesAdapter {
        qml: "./Main.qml"
    }
}
