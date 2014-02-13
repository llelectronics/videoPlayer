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

#include "DownloadManager.hpp"

#include <QtCore/QFileInfo>
#include <QtCore/QTimer>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkRequest>
#include <QDir>

DownloadManager::DownloadManager(QObject *parent)
    : QObject(parent), m_currentDownload(0), m_downloadedCount(0), m_totalCount(0), m_progressTotal(0), m_progressValue(0)
{
}

QString DownloadManager::errorMessage() const
{
    return m_errorMessage.join("\n");
}

QString DownloadManager::statusMessage() const
{
    return m_statusMessage.join("\n");
}

int DownloadManager::activeDownloads() const
{
    return m_downloadQueue.count();
}

int DownloadManager::progressTotal() const
{
    return m_progressTotal;
}

int DownloadManager::progressValue() const
{
    return m_progressValue;
}

QString DownloadManager::progressMessage() const
{
    return m_progressMessage;
}

void DownloadManager::downloadUrl(const QString &url)
{
    append(QUrl(url));
}

void DownloadManager::append(const QUrl &url)
{
    /**
     * If there is no job in the queue at the moment or we do
     * not process any job currently, then we trigger the processing
     * of the next job.
     */
    if (m_downloadQueue.isEmpty() && !m_currentDownload)
        QTimer::singleShot(0, this, SLOT(startNextDownload()));

    // Enqueue the new URL to the job queue
    m_downloadQueue.enqueue(url);
    emit activeDownloadsChanged();

    // Increment the total number of jobs
    ++m_totalCount;
}

QString DownloadManager::saveFileName(const QUrl &url)
{
    // First extract the path component from the URL ...
    const QString path = url.path();

    // ... and then extract the file name.
    QString basename = QFileInfo(path).fileName();

    if (basename.isEmpty())
        basename = "download";

    // Replace the file name with 'download' if the URL provides no file name.
    basename = QDir::homePath() + "/Videos/" + basename; // locate in tmp directory

    /**
     * Check if the file name exists already, if so, append an increasing number and test again.
     */
    if (QFile::exists(basename)) {
        // already exists, don't overwrite
        int i = 0;
        basename += '.';
        while (QFile::exists(basename + QString::number(i)))
            ++i;

        basename += QString::number(i);
    }

    return basename;
}

void DownloadManager::addErrorMessage(const QString &message)
{
    m_errorMessage.append(message);
    emit errorMessageChanged();
}

void DownloadManager::addStatusMessage(const QString &message)
{
    m_statusMessage.append(message);
    emit statusMessageChanged();
}

//! [0]
void DownloadManager::startNextDownload()
{
    // If the queue is empty just add a new status message
    if (m_downloadQueue.isEmpty()) {
        addStatusMessage(QString("%1/%2 files downloaded successfully").arg(m_downloadedCount).arg(m_totalCount));
        return;
    }

    // Otherwise dequeue the first job from the queue ...
    const QUrl url = m_downloadQueue.dequeue();

    // ... and determine a local file name where the result can be stored.
    const QString filename = saveFileName(url);

    // Open the file with this file name for writing
    m_output.setFileName(filename);
    if (!m_output.open(QIODevice::WriteOnly)) {
        addErrorMessage(QString("Problem opening save file '%1' for download '%2': %3").arg(filename, url.toString(), m_output.errorString()));

        startNextDownload();
        return; // skip this download
    }

    // Now create the network request for the URL ...
    QNetworkRequest request(url);

    // ... and start the download.
    m_currentDownload = m_manager.get(request);

    // Connect against the necessary signals to get informed about progress and status changes
    connect(m_currentDownload, SIGNAL(downloadProgress(qint64, qint64)),
            SLOT(downloadProgress(qint64, qint64)));
    connect(m_currentDownload, SIGNAL(finished()), SLOT(downloadFinished()));
    connect(m_currentDownload, SIGNAL(readyRead()), SLOT(downloadReadyRead()));

    // Add a status message
    addStatusMessage(QString("Downloading %1...").arg(url.toString()));

    // Start the timer so that we can calculate the download speed later on
    m_downloadTime.start();
}
//! [0]

//! [1]
void DownloadManager::downloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    // Update the properties with the new progress values
    m_progressTotal = bytesTotal;
    m_progressValue = bytesReceived;
    emit progressTotalChanged();
    emit progressValueChanged();

    // Calculate the download speed ...
    double speed = bytesReceived * 1000.0 / m_downloadTime.elapsed();
    QString unit;
    if (speed < 1024) {
        unit = "bytes/sec";
    } else if (speed < 1024 * 1024) {
        speed /= 1024;
        unit = "kB/s";
    } else {
        speed /= 1024 * 1024;
        unit = "MB/s";
    }

    // ... and update the progress message.
    m_progressMessage = QString("%1 %2").arg(speed, 3, 'f', 1).arg(unit);
    emit progressMessageChanged();
}
//! [1]

//! [2]
void DownloadManager::downloadFinished()
{
    // Reset the progress information when the download has finished
    m_progressTotal = 0;
    m_progressValue = 0;
    m_progressMessage.clear();
    emit progressValueChanged();
    emit progressTotalChanged();
    emit progressMessageChanged();

    // Close the file where the data have been written
    m_output.close();

    // Add a status or error message
    if (m_currentDownload->error()) {
        addErrorMessage(QString("Failed: %1").arg(m_currentDownload->errorString()));
    } else {
        addStatusMessage("Succeeded.");
        ++m_downloadedCount;
    }

    /**
     * We can't call 'delete m_currentDownload' here, because this method might have been invoked directly as result of a signal
     * emission of the network reply object.
     */
    m_currentDownload->deleteLater();
    m_currentDownload = 0;
    emit activeDownloadsChanged();

    // Trigger the execution of the next job
    startNextDownload();
}
//! [2]

//! [3]
void DownloadManager::downloadReadyRead()
{
    // Whenever new data are available on the network reply, write them out to the result file
    m_output.write(m_currentDownload->readAll());
}
//! [3]

//! [4]
void DownloadManager::downloadAbort()
{
    m_currentDownload->abort();
}
//! [4]
