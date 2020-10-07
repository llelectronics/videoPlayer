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
#include <QFileDevice>

class ythelper : public QObject
{   Q_OBJECT
    Q_PROPERTY(int searchResultNumber READ searchResultNumber WRITE setSearchResultNumber)
public:
    QString reqUrl;
    QString streamUrl;
    QString streamTitle;
    QString errorMsg;
    QString parameter;
    QProcess streamProcess;
    QProcess titleProcess;
    QProcess updateBinary;
    QString data_dir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QString music_dir = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
    int searchResultNumber() { return m_searchResultNumber; }
    void setSearchResultNumber(int nr) { m_searchResultNumber = nr; }
//    bool ffmpegAvailable = false;
private:
    QString _oggAudio;
    QString _opusAudio;
    QString _fullHdVideo;
    QString _fullHdAudio;
    QString _format;
    QProcess oggProcess;
    QProcess opusProcess;
    QProcess fullHdProcess;
    QProcess searchProcess;
    int m_searchResultNumber = 11;
signals:
    void streamUrlChanged(QString changedUrl);
    void sTitleChanged(QString sTitle);
    void updateComplete();
    void downloadComplete();
    void error(QString message);
    void oggAudioChanged();
    void opusAudioChanged();
    void fullHdChanged();
    void ytSearchResultsChanged(QString ytSearchResultsJson);
public slots:
    void setUrl(QString url)
    {
        reqUrl = url;
    }
    void setParameter(QString param)
    {
        parameter = param;
    }
    QString getReqUrl()
    {
        return reqUrl;
    }
//    bool getFfmpegAvailable()
//    {
//        return ffmpegAvailable;
//    }
    QString getOggAudioUrl()
    {
        return _oggAudio;
    }
    QString getOpusAudioUrl()
    {
        return _opusAudio;
    }
    QString getFullHdVideoUrl()
    {
        return _fullHdVideo;
    }
    QString getFullHdAudioUrl()
    {
        return _fullHdAudio;
    }
    void checkAndInstall()
    {
        QFile ytdlBin;
        ytdlBin.setFileName(data_dir + "/youtube-dl");
        if (!ytdlBin.exists()) {
            ytdlBin.setFileName("/usr/share/harbour-videoPlayer/qml/pages/helper/youtube-dl");
            if (ytdlBin.exists()) {
                ytdlBin.setFileName("/usr/share/harbour-videoPlayer/qml/pages/helper/youtube-dl");
                ytdlBin.copy(data_dir + "/youtube-dl");
            }
            else {
                QProcess *ytdlBinDownload;
                ytdlBinDownload->start("curl -L https://yt-dl.org/downloads/latest/youtube-dl -o " + data_dir + "/youtube-dl");
                ytdlBinDownload->waitForFinished();
            }
            ytdlBin.setFileName(data_dir + "/youtube-dl");
        }
        ytdlBin.setPermissions(QFileDevice::ExeUser|QFileDevice::ExeGroup|QFileDevice::ExeOther|QFileDevice::ReadUser|QFileDevice::ReadGroup|QFileDevice::ReadOther|QFileDevice::WriteUser|QFileDevice::WriteGroup|QFileDevice::WriteOther);

//        // Detect ffmpeg binary from Encode App
//        QFile ffmpegBin;
//        ffmpegBin.setFileName("/usr/share/harbour-encode/ffmpeg_static");
//        if (ffmpegBin.exists()) {
//            //qDebug() << "ffmpegbin exists";
//            ffmpegAvailable = true;
//            QFile ffmpegHelperBin;
//            ffmpegHelperBin.setFileName(data_dir + "/ffmpeg");
//            if (!ffmpegHelperBin.exists()) {
//                ffmpegBin.link(data_dir + "/ffmpeg");
//            }
//        }
//        else {
//            //qDebug() << "ffmpegbin does not exist";
//            ffmpegAvailable = false;
//        }
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
        streamProcess.start(data_dir + "/youtube-dl " + parameter + " -g " + reqUrl);
        connect(&streamProcess, SIGNAL(finished(int)), this, SLOT(getStreamUrlOutput(int)));
    }
    void getStreamTitle()
    {
        //qDebug() << "Starting process with url:" << reqUrl;
        checkAndInstall();
        titleProcess.start(data_dir + "/youtube-dl -e " + reqUrl);
        connect(&titleProcess, SIGNAL(finished(int)), this, SLOT(getTitleOutput(int)));
    }
    void getMusicUrls()
    {
        getVorbisUrl();
        getOpusUrl();
    }

    void getDashUrls()
    {
        getFullHdUrls();
    }

    void getFullHdUrls()
    {
        checkAndInstall();
        parameter = " ";
        parameter += "-f 137,140";
        //parameter += "-f 248,251";
        fullHdProcess.start(data_dir + "/youtube-dl " + parameter + " -g " + reqUrl);
        connect(&fullHdProcess, SIGNAL(finished(int)), this, SLOT(getFullHdUrlOutput(int)));
    }
    void getVorbisUrl()
    {
        checkAndInstall();
        parameter = " ";
        parameter += "-f 171";
        oggProcess.start(data_dir + "/youtube-dl " + parameter + " -g " + reqUrl);
        connect(&oggProcess, SIGNAL(finished(int)), this, SLOT(getOggUrlOutput(int)));
    }
    void getOpusUrl()
    {
        checkAndInstall();
        parameter = " ";
        parameter += "-f 251";
        opusProcess.start(data_dir + "/youtube-dl " + parameter + " -g " + reqUrl);
        connect(&opusProcess, SIGNAL(finished(int)), this, SLOT(getOpusUrlOutput(int)));
    }
    void getYtSearchResults(QString searchTerm) {
        checkAndInstall();
        parameter = " ";
        parameter += "-J \"ytsearch" + QString::number(m_searchResultNumber) + ":" + searchTerm.toUtf8() + "\"";
        searchProcess.start(data_dir + "/youtube-dl " + parameter);
        connect(&searchProcess, SIGNAL(finished(int)), this, SLOT(getYtSearchResultsOutput(int)));
    }
    void getFullHdUrlOutput(int exitCode)
    {
        if (exitCode == 0) {
            QByteArray out = fullHdProcess.readAllStandardOutput();
            QList<QByteArray> outputList = out.split('\n');
            qDebug() << "Called the C++ slot and got following url:" << outputList[0];
            _fullHdVideo = outputList[0];
            _fullHdAudio = outputList[1];
            fullHdChanged();
        }
        else {
            printError(&oggProcess);
        }
    }
    void getOggUrlOutput(int exitCode)
    {
        if (exitCode == 0) {
            QByteArray out = oggProcess.readAllStandardOutput();
            QList<QByteArray> outputList = out.split('\n');
            qDebug() << "Called the C++ slot and got following url:" << outputList[0];
            _oggAudio = outputList[0];
            oggAudioChanged();
        }
        else {
            printError(&oggProcess);
        }
    }
    void getOpusUrlOutput(int exitCode)
    {
        if (exitCode == 0) {
            QByteArray out = opusProcess.readAllStandardOutput();
            QList<QByteArray> outputList = out.split('\n');
            qDebug() << "Called the C++ slot and got following url:" << outputList[0];
            _opusAudio = outputList[0];
            opusAudioChanged();
        }
        else {
            printError(&opusProcess);
        }
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
            printError(&streamProcess);
        }
    }
    void printError(QProcess *pProcess)
    {
        QByteArray errorOut = pProcess->readAllStandardError();
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
        else {
            printError(&updateBinary);
        }
    }
    void getYtSearchResultsOutput(int exitCode)
    {
        if (exitCode == 0) {
            QByteArray out = searchProcess.readAllStandardOutput();
            emit ytSearchResultsChanged(QString(out));
        }
        else {
            printError(&searchProcess);
        }
    }
    void killYtSearch() {
        searchProcess.close();
    }
};

#endif // YOUTUBEDLHELPER_HPP
