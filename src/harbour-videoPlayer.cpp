/*
  Copyright (C) Leszek Lesner.
  Contact: Leszek Lesner <leszek.lesner@web.de>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifdef QT_QML_DEBUG
#include <QtQuick>
#include <QDebug>
#endif

#include <sailfishapp.h>
#include "DownloadManager.hpp"


int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView(); // I get a white background with this.
    view->setSource(SailfishApp::pathTo("qml/harbour-videoPlayer.qml"));  // So I do this ;)

    QObject *object = view->rootObject();

    QString file;
    bool autoPlay = false;
    for(int i=1; i<argc; i++) {
        if(QString(argv[i]) == "-p" ) {  // use -p option as autoplay argument
            autoPlay = true;
        }
        if (!QString(argv[i]).startsWith("/") && !QString(argv[i]).startsWith("http://") && !QString(argv[i]).startsWith("rtsp://")
                && !QString(argv[i]).startsWith("mms://") && !QString(argv[i]).startsWith("file://") && !QString(argv[i]).startsWith("https://")) {
            QString pwd("");
            char * PWD;
            PWD = getenv ("PWD");
            pwd.append(PWD);
            file = pwd + "/" + QString(argv[i]);
        }
        else file = QString(argv[i]);
    }
    if (autoPlay == true) object->setProperty("autoPlay", true);

    QMetaObject::invokeMethod(object, "loadUrl", Q_ARG(QVariant, file));

    // Create download manager object
    DownloadManager manager;

    view->engine()->rootContext()->setContextProperty("_manager", &manager);

    view->show();

    return app->exec();

}

