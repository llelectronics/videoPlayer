#include "playlist.h"

Playlist::Playlist(QObject *parent) :
    QObject(parent){
    playlist = new QMediaPlaylist;
}

bool Playlist::setPllist(const QString &pllist){
    QFile inputList(pllist);
    if (inputList.open(QIODevice::ReadOnly)){
        playlist->clear();
        QTextStream in(&inputList);
        while ( !in.atEnd() ){
          QString line = in.readLine();
          if(line.at(0) == 'F'){
              while(line.at(0) != '=')
                  line.remove(0,1);
              line.remove(0,1);
              playlist->addMedia(QUrl(line));
          }
        }
        inputList.close();

        if(playlist->error()){
            qDebug() << playlist->errorString();
            return false;
        }else{
            playlist->setPlaybackMode(QMediaPlaylist::Loop);
            playlist->setCurrentIndex(1);
            return true;
        }
    }else{
        qDebug() << "Cannot open source: "+pllist;
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
