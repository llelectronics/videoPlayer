#ifndef YOUTUBEDLHELPER_HPP
#define YOUTUBEDLHELPER_HPP

#include <QtCore/QObject>
#include <QString>
#include <QStandardPaths>
#include <QDebug>
#include <QProcess>
#include <QByteArray>
#include <QFile>
#include <QStandardPaths>

class ythelper : public QObject
{   Q_OBJECT
public:
    QString reqUrl;
    QString streamUrl;
    QString streamTitle;
    QString errorMsg;
    QProcess streamProcess;
    QProcess titleProcess;
    QProcess updateBinary;
    QString data_dir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
signals:
    void streamUrlChanged(QString changedUrl);
    void sTitleChanged(QString sTitle);
    void updateComplete();
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
    void checkAndInstall()
    {
        QFile ytdlBin;
        ytdlBin.setFileName(data_dir + "/youtube-dl");
        if (!ytdlBin.exists()) {
            ytdlBin.setFileName("/usr/share/harbour-videoPlayer/qml/pages/helper/youtube-dl");
            ytdlBin.copy(data_dir + "/youtube-dl");
        }
    }
    void updateYtdl()
    {
        checkAndInstall();
        updateBinary.start(data_dir + "/youtube-dl -U");
        connect(&updateBinary, SIGNAL(finished(int)), this, SLOT(getUpdateStatus(int)));
    }

    void getStreamUrl()
    {
        //qDebug() << "Starting process with url:" << reqUrl;
        checkAndInstall();
        streamProcess.start(data_dir + "/youtube-dl -g " + reqUrl);
        connect(&streamProcess, SIGNAL(finished(int)), this, SLOT(getStreamUrlOutput(int)));
    }
    void getStreamTitle()
    {
        //qDebug() << "Starting process with url:" << reqUrl;
        checkAndInstall();
        titleProcess.start(data_dir + "/youtube-dl -e " + reqUrl);
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
    void getUpdateStatus(int exitCode)
    {
        if (exitCode == 0) {
            updateComplete();
        }
    }
};

#endif // YOUTUBEDLHELPER_HPP
