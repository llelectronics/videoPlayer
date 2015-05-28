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
    QString streamUrl;
    QString errorMsg;
    QProcess process;
signals:
    void streamUrlChanged(QString changedUrl);
    void error(QString message);
public slots:
    void setUrl(QString url)
    {
        reqUrl = url;
    }
    QString getReqUrl()
    {
        return reqUrl;
    }
    void getStreamUrl()
    {

        //qDebug() << "Starting process with url:" << reqUrl;
        process.start("/usr/share/harbour-videoPlayer/qml/pages/helper/youtube-dl -g " + reqUrl);

        connect(&process, SIGNAL(readyReadStandardOutput()), this, SLOT(printOutput()));
        connect(&process, SIGNAL(readyReadStandardError()), this, SLOT(printError()));

        //process.waitForFinished(-1);
        //qDebug() << "Called the C++ slot and got following url:" << out.simplified();
        //return out.simplified();
    }
    void printOutput()
    {
        QByteArray out = process.readAllStandardOutput();
        qDebug() << "Called the C++ slot and got following url:" << out.simplified();
        streamUrl = out.simplified();
        streamUrlChanged(streamUrl);
    }
    void printError()
    {
        QByteArray errorOut = process.readAllStandardError();
        qDebug() << "Called the C++ slot and got following error:" << errorOut.simplified();
        errorMsg = errorOut.simplified();
        error(errorMsg);
    }
};

#endif // YOUTUBEDLHELPER_HPP
