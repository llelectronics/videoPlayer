/****************************************************************************
 **
 ** Portions Copyright (C) 2012 Research In Motion Limited.
 ** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
 ** All rights reserved.
 ** Contact: Research In Motion Ltd. (http://www.rim.com/company/contact/)
 ** Contact: Nokia Corporation (qt-info@nokia.com)
 **
 ** This file is part of the examples of the BB10 Platform and is derived
 ** from a similar file that is part of the Qt Toolkit.
 **
 ** You may use this file under the terms of the BSD license as follows:
 **
 ** "Redistribution and use in source and binary forms, with or without
 ** modification, are permitted provided that the following conditions are
 ** met:
 **   * Redistributions of source code must retain the above copyright
 **     notice, this list of conditions and the following disclaimer.
 **   * Redistributions in binary form must reproduce the above copyright
 **     notice, this list of conditions and the following disclaimer in
 **     the documentation and/or other materials provided with the
 **     distribution.
 **   * Neither the name of Research In Motion, nor the name of Nokia
 **     Corporation and its Subsidiary(-ies), nor the names of its
 **     contributors may be used to endorse or promote products
 **     derived from this software without specific prior written
 **     permission.
 **
 ** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 ** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 ** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 ** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 ** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 ** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 ** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 ** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 ** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 ** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 ** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 **
 ****************************************************************************/

#ifndef DOWNLOADMANAGER_HPP
#define DOWNLOADMANAGER_HPP

#include <QtCore/QFile>
#include <QtCore/QObject>
#include <QtCore/QQueue>
#include <QtCore/QStringList>
#include <QtCore/QTime>
#include <QtCore/QUrl>
#include <QtNetwork/QNetworkAccessManager>

class QNetworkReply;

/**
 * The DownloadManager encapsulates the download and saving of URLs.
 * Error and status messages are available to the UI via properties as well as the number
 * of currently running downloads.
 * Additionally it provides progress information for the currently running download.
 */
class DownloadManager : public QObject
{
    Q_OBJECT

    // Makes error messages available to the UI
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

    // Makes status messages available to the UI
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)

    // Makes the number of currently running downloads available to the UI
    Q_PROPERTY(int activeDownloads READ activeDownloads NOTIFY activeDownloadsChanged)

    // Makes the total number of bytes of the current download available to the UI
    Q_PROPERTY(int progressTotal READ progressTotal NOTIFY progressTotalChanged)

    // Makes the already downloaded number of bytes of the current download available to the UI
    Q_PROPERTY(int progressValue READ progressValue NOTIFY progressValueChanged)

    // Makes the progress message available to the UI
    Q_PROPERTY(QString progressMessage READ progressMessage NOTIFY progressMessageChanged)

public:
    DownloadManager(QObject *parent = 0);

    // The accessor methods for the properties
    QString errorMessage() const;
    QString statusMessage() const;
    QString basename;
    int activeDownloads() const;
    int progressTotal() const;
    int progressValue() const;
    QString progressMessage() const;

public Q_SLOTS:
    // This method is called when the user starts a download by clicking the 'Download' button in the UI
    void downloadUrl(const QString &url);
    void downloadAbort();

Q_SIGNALS:
    // The change notification signals of the properties
    void errorMessageChanged();
    void statusMessageChanged();
    void activeDownloadsChanged();
    void progressTotalChanged();
    void progressValueChanged();
    void progressMessageChanged();

private Q_SLOTS:
    // This method starts the next download from the internal job queue
    void startNextDownload();

    // This method is called whenever the progress of the current download job has changed
    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);

    // This method is called whenever a download job has finished
    void downloadFinished();

    // This method is called whenever the current download job received new data
    void downloadReadyRead();

private:
    // Enqueues a new download to the internal job queue
    void append(const QUrl &url);

    // This method determines a file name that can be used to save the given URL
    QString saveFileName(const QUrl &url);

    // A helper method to collect error messages
    void addErrorMessage(const QString &message);

    // A helper method to collect status messages
    void addStatusMessage(const QString &message);

    // The network access manager that does all the network communication
    QNetworkAccessManager m_manager;

    // The internal job queue
    QQueue<QUrl> m_downloadQueue;

    // The currently running download job
    QNetworkReply *m_currentDownload;

    // The file where the downloaded data are saved
    QFile m_output;

    // The time when the download started (used to calculate download speed)
    QTime m_downloadTime;

    // The number of finished download jobs
    int m_downloadedCount;

    // The total number of download jobs
    int m_totalCount;

    // The total number of bytes to transfer for the current download job
    int m_progressTotal;

    // The number of already transferred bytes for the current download job
    int m_progressValue;

    // A textual representation of the current progress status
    QString m_progressMessage;

    // The list of error messages
    QStringList m_errorMessage;

    // The list of status messages
    QStringList m_statusMessage;
};

#endif
