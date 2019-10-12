#ifndef VIDEOHELPER_HPP
#define VIDEOHELPER_HPP

#include <QObject>
#include <QDBusConnection>
#include <QDBusMessage>


class videoHelper : public QObject
{   Q_OBJECT
public slots:
    void disableBlanking()
    {
        QDBusMessage message = QDBusMessage::createMethodCall(
                    "com.nokia.mce",
                    "/com/nokia/mce/request",
                    "com.nokia.mce.request",
                    "req_display_blanking_pause");
        QDBusConnection connection(QDBusConnection::systemBus());
        connection.send(message);
    }
    void enableBlanking()
    {
        QDBusMessage message = QDBusMessage::createMethodCall(
                    "com.nokia.mce",
                    "/com/nokia/mce/request",
                    "com.nokia.mce.request",
                    "req_display_cancel_blanking_pause");
        QDBusConnection connection(QDBusConnection::systemBus());
        connection.send(message);
    }
};

#endif // VIDEOHELPER_HPP
