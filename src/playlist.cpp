#include "playlist.h"
#include <QDebug>

Playlist::Playlist(QObject *parent) :
    QObject(parent){
    playlist = new QMediaPlaylist;
}

bool Playlist::setPllist(const QString &pllist){
    //qDebug() << "Trying to load:" +pllist;
    //playlist->load(QUrl::fromUserInput(pllist));
    QFile inputList(pllist);
    if (inputList.open(QIODevice::ReadOnly)){
        playlist->clear();
        QTextStream in(&inputList);
        in.setCodec("UTF-8");
        while ( !in.atEnd() ){
          QString line = in.readLine();
          if (!line.isEmpty()) {
              if(line.at(0) == 'F'){
                  while(line.at(0) != '=')
                      line.remove(0,1);
                  line.remove(0,1);
                  playlist->addMedia(QUrl(line));
              }
          }
        }
        inputList.close();

        if(playlist->error()){
            qDebug() << playlist->errorString();
            return false;
        }else{
            emit pllistChanged();
            mCurrent = pllist;
            return true;
       }
    }else{
        qDebug() << "Cannot open playlist: "+pllist;
        qDebug() << "It might be a new created by the user";
        return false;
    }
}

void Playlist::add(QString track){
    playlist->addMedia(QUrl(track));
}

void Playlist::remove(int pos){
    playlist->removeMedia(pos);
}

QString Playlist::get(int pos){
    return playlist->media(pos).canonicalUrl().toString();
}

void Playlist::insert(int pos, QString track){
    playlist->insertMedia(pos,QUrl(track));
}

int Playlist::count() {
    return playlist->mediaCount();
}

bool Playlist::save(QString filename) {
    //qDebug() << "Save called with filename:" + file;
    //playlist->save(QUrl::fromLocalFile("/home/nemo/Music/playlists/test.m3u"), "m3u");
    QFile file(filename);
    if (file.open(QIODevice::WriteOnly))
    {
        QTextStream ts(&file);
        ts << plsEncode();
        file.close();
        return true;
    }
    else {
        qDebug() << ("PlayListParser: unable to save playlist, error: %s", qPrintable(file.errorString()));
        return false;
    }
}

QString Playlist::getError() {
    return playlist->errorString();
}

void Playlist::clearError() {
    playlist->clear();
}

QString Playlist::plsEncode() {
    QStringList out;
    out << QString("[playlist]");
    for (int counter = 1; counter <= playlist->mediaCount(); counter++)
    {
        qDebug() << "Writing: " + playlist->media(counter-1).canonicalUrl().toString() + " Counter is: " + QString::number(counter) + " mediaCount is: " + QString::number(playlist->mediaCount());
        QString begin = "File" + QString::number(counter) + "=";
        out.append(begin + playlist->media(counter-1).canonicalUrl().toString());
        //        begin = "Title" + QString::number(counter) + "="; //TODO: activate when we have title loading implemented
        //        out.append(begin + f->value(Qmmp::TITLE));
        //        begin = "Length" + QString::number(counter) + "=";
        //        out.append(begin + QString::number(f->length()));
    }
    out << "NumberOfEntries=" + QString::number(playlist->mediaCount());
    return out.join("\n");
}
