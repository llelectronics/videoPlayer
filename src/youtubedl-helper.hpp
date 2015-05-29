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
    QString streamTitle;
    QString errorMsg;
    QProcess streamProcess;
    QProcess titleProcess;
signals:
    void streamUrlChanged(QString changedUrl);
    void sTitleChanged(QString sTitle);
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
        streamProcess.start("/usr/share/harbour-videoPlayer/qml/pages/helper/youtube-dl -g " + reqUrl);
        connect(&streamProcess, SIGNAL(finished(int)), this, SLOT(getStreamUrlOutput(int)));
    }
    void getStreamTitle()
    {
        //qDebug() << "Starting process with url:" << reqUrl;
        titleProcess.start("/usr/share/harbour-videoPlayer/qml/pages/helper/youtube-dl -e " + reqUrl);
        connect(&titleProcess, SIGNAL(finished(int)), this, SLOT(getTitleOutput(int)));
    }
    void getStreamUrlOutput(int exitCode)
    {
        if (exitCode == 0) {
            QByteArray out = streamProcess.readAllStandardOutput();
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
        QByteArray errorOut = streamProcess.readAllStandardError();
        qDebug() << "Called the C++ slot and got following error:" << errorOut.simplified();
        errorMsg = errorOut.simplified();
        error(errorMsg);
    }
    void getTitleOutput(int exitCode)
    {
        if (exitCode == 0) {
            QByteArray out = titleProcess.readAllStandardOutput();
            QList<QByteArray> outputList = out.split('\n');
            qDebug() << "Called the C++ slot and got following url:" << outputList[0];
            streamTitle = outputList[0];
            sTitleChanged(streamTitle);
        }
    }
};

#endif // YOUTUBEDLHELPER_HPP
