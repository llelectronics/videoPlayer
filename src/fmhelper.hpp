#ifndef FMHELPER_HPP
#define FMHELPER_HPP

#include <QtCore/QObject>
#include <QtCore/QFile>
#include <QDebug>

class FM : public QObject
{   Q_OBJECT
    public slots:
        void remove(const QString &url)
        {    qDebug() << "Called the C++ slot and request removal of:" << url;
             QFile(url).remove();
        }
};


#endif // FMHELPER_HPP
