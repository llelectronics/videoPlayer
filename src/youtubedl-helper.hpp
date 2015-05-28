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

        connect(&process, SIGNAL(finished(int)), this, SLOT(printOutput(int)));

        //process.waitForFinished(-1);
        //qDebug() << "Called the C++ slot and got following url:" << out.simplified();
        //return out.simplified();
    }
    void printOutput(int exitCode)
    {
        if (exitCode == 0) {
            QByteArray out = process.readAllStandardOutput();
            QList<QByteArray> outputList = out.split('\n');
            qDebug() << "Called the C++ slot and got following url:" << outputList[0];
            streamUrl = outputList[0];
            streamUrlChanged(streamUrl);
        }
        else {
            printError();
        }
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
