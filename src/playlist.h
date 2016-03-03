#ifndef PLAYLIST_H
#define PLAYLIST_H

#include <QtMultimedia/QMediaPlaylist>
#include <QFile>
#include <QTextStream>
#include <QTime>
#include <QDebug>
#include <QtMultimedia/QMediaObject>
#include <QtMultimedia/QMediaContent>

class Playlist : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QString pllist READ pllist WRITE setPllist)
    explicit Playlist(QObject *parent = 0);

    QString pllist() { return mCurrent; }
    Q_INVOKABLE bool setPllist(const QString &pllist);

public slots:
    void add(QString track);
    void remove(int pos);
    QString get(int pos);
    void insert(int pos, QString track);
    int count();

private:
    QMediaPlaylist *playlist;
    QString mCurrent;

};

#endif // PLAYLIST_H

