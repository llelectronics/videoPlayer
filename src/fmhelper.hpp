#ifndef FMHELPER_HPP
#define FMHELPER_HPP

#include <QtCore/QObject>
#include <QtCore/QFile>
#include <QString>
#include <QDebug>
#include <QDir>

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
};


#endif // FMHELPER_HPP
