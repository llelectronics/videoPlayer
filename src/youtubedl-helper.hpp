#ifndef YOUTUBEDLHELPER_HPP
#define YOUTUBEDLHELPER_HPP

#include <QtCore/QObject>
#include <QString>
#include <QStandardPaths>
#include <QDebug>
#include <QProcess>
#include <QByteArray>

class ythelper : public QObject
{   Q_OBJECT
public:
    QString reqUrl;
public slots:
    void setUrl(QString url)
    {
        reqUrl = url;
    }
    QString getStreamUrl()
    {
        QProcess process;
        //qDebug() << "Starting process with url:" << reqUrl;
        process.start("/usr/share/harbour-videoPlayer/qml/pages/helper/youtube-dl -g " + reqUrl);
        process.waitForFinished(-1);
        QByteArray out = process.readAllStandardOutput();
        //qDebug() << "Called the C++ slot and got following url:" << out.simplified();
        return out.simplified();
    }
};

#endif // YOUTUBEDLHELPER_HPP
