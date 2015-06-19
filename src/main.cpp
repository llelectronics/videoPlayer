/*
 * Copyright (C) 2014  Vishesh Handa <vhanda@kde.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlComponent>

#include <QStandardPaths>
#include <QDebug>
#include <QThread>

#include <KDBusService>
#include <KLocalizedString>

#include <QApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>

#include <iostream>

int main(int argc, char** argv)
{
    QApplication app(argc, argv);
    app.setApplicationDisplayName("LLs vPlayer");

    KDBusService service(KDBusService::Unique);

    QCommandLineParser parser;
    //parser.addOption(QCommandLineOption("reset", i18n("Reset the database")));
    parser.addOption(QCommandLineOption("phone", i18n("Run the phone version of vPlayer")));
    parser.addHelpOption();
    parser.process(app);

    if (parser.positionalArguments().size() > 1) {
        parser.showHelp(1);
    }

//     if (parser.isSet("reset")) {
//         KokoConfig config;
//         config.reset();
// 
//         ImageStorage::reset();
//     }

    QStringList locations = QStandardPaths::standardLocations(QStandardPaths::MoviesLocation);
    Q_ASSERT(locations.size() >= 1);
    qDebug() << locations;

    QQmlEngine engine;

    QString path;
    if (parser.isSet("phone") || qgetenv("PLASMA_PLATFORM") == QByteArray("phone")) {
        path = QStandardPaths::locate(QStandardPaths::DataLocation, "main.qml");
        //qDebug() << "[DEBUG QStandardPaths::DataLocation] : " + QStandardPaths::DataLocation; 
        //qDebug() << "[DEBUG path] : " + path;
    }
    QQmlComponent component(&engine, path);
    if (component.isError()) {
        std::cout << component.errorString().toUtf8().constData() << std::endl;
        Q_ASSERT(0);
    }
    Q_ASSERT(component.status() == QQmlComponent::Ready);
    component.create();

    int rt = app.exec();
    return rt;
}
