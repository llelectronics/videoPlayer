#include "playlist.h"

Playlist::Playlist(QObject *parent) :
    QObject(parent){
    playlist = new QMediaPlaylist;
}

bool Playlist::setPllist(const QString &pllist){
    //qDebug() << "Trying to load:" +pllist;
    QFile inputList(pllist);
    if (inputList.open(QIODevice::ReadOnly)){
        playlist->clear();
        QTextStream in(&inputList);
        in.setCodec("UTF-8");
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
            emit pllistChanged();
            mCurrent = pllist;
            return true;
        }
    }else{
        qDebug() << "Cannot open playlist: "+pllist;
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

void Playlist::save(QString file) {
    //qDebug() << "Save called with filename:" + file;
    playlist->save(QUrl::fromLocalFile(file));
}
