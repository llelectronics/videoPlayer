#ifndef FMHELPER_HPP
#define FMHELPER_HPP

#include <QtCore/QObject>
#include <QtCore/QFile>
#include <QString>
#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QMimeType>
#include <QUrl>

class FM : public QObject
{   Q_OBJECT
    public slots:
        void remove(const QString &url)
        {    //qDebug() << "Called the C++ slot and request removal of:" << url;
             QFile(url).remove();
        }
        QString getHome()
        {    //qDebug() << "Called the C++ slot and request removal of:" << url;
             return QDir::homePath();
        }
        QString getRoot()
        {    //qDebug() << "Called the C++ slot and request removal of:" << url;
             return QDir::rootPath();
        }
        bool existsPath(const QString &url)
        {
            return QDir(url).exists();
        }
        bool isFile(const QString &url)
        {
            return QFileInfo(url).isFile();
        }
        QString getMime(const QString &url)
        {
            QMimeDatabase db;
            QUrl path(url);
            QMimeType mime;

            QRegExp regex(QRegExp("[_\\d\\w\\-\\. ]+\\.[_\\d\\w\\-\\. ]+"));
            QString filename = url.split('/').last();
            int idx = filename.indexOf(regex);

            if(filename.isEmpty() || (idx == -1))
                mime = db.mimeTypeForUrl(path);
            else
                mime = db.mimeTypeForFile(filename.mid(idx, regex.matchedLength()));
            return mime.name();
        }
};


#endif // FMHELPER_HPP
