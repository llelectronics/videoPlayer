import QtQuick 2.0

Timer {
    id: timer

    property alias suspend: timer.running

    interval: 60000
    repeat: true
    triggeredOnStart: true
    onTriggered: _videoHelper.disableBlanking();

    onRunningChanged: {
        if (!running) {
            _videoHelper.enableBlanking();
        }
    }
}
