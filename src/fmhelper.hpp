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
#include <QStandardPaths>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>
#include <QFutureWatcher>
#include <QStorageInfo>

class FM : public QObject
{   Q_OBJECT

    Q_PROPERTY (QString sourceUrl READ sourceUrl WRITE setSourceUrl NOTIFY sourceUrlChanged)
    Q_PROPERTY (bool moveMode READ isMoveMode WRITE setMoveMode)
    Q_PROPERTY (bool cpResult READ cpResult NOTIFY cpResultChanged)

    signals:
        void sourceUrlChanged();
        void cpResultChanged();
        void dirSizeChanged(quint64 dirSize);
    private:
        QString m_sourceUrl;
        bool m_moveMode;
        QString m_dataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
        QString m_docDir = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
        QFutureWatcher<bool> watcher;
        QFutureWatcher<quint64> dirWatcher;
        bool m_cpResult;
        quint64 m_dirSize;
    private slots:
        void setSourceUrl(const QString &url) { m_sourceUrl = url; emit sourceUrlChanged();}
        void setMoveMode(bool &mode) { m_moveMode = mode;}
    public:
        QString sourceUrl() {return m_sourceUrl;}
        bool isMoveMode() {return m_moveMode;}
        bool cpResult() {return m_cpResult;}
        //quint64 dirSize() { return m_dirSize; }
    public slots:
        void remove(const QString &url)
        {    //qDebug() << "Called the C++ slot and request removal of:" << url;
             QFile(url).remove();
        }
        void removeDir(const QString &url)
        {
            QDir(url).removeRecursively();
        }
        QString getHome()
        {    //qDebug() << "Called the C++ slot and request removal of:" << url;
             return QDir::homePath();
        }
        QString getRoot()
        {    //qDebug() << "Called the C++ slot and request removal of:" << url;
             return QDir::rootPath();
        }
        QString getSDCard()
        {
            foreach (const QStorageInfo &storage, QStorageInfo::mountedVolumes()) {
                    if (storage.isValid() && storage.isReady() && storage.device().indexOf("mmcblk1p1") != -1) {
//                        qDebug() << "DEBUG STORAGE rootPath: " + storage.rootPath();
//                        qDebug() << "DEBUG STORAGE device: " + storage.device();
                        return storage.rootPath();
                    }
            }
            return "";
        }
        QString data_dir()
        {
            return m_dataDir;
        }
        QString documents_dir()
        {
            return m_docDir;
        }
        bool existsPath(const QString &url)
        {
            return QDir(url).exists();
        }
        bool isFile(const QString &url)
        {
            return QFileInfo(url).isFile();
        }
        bool isSymLink(const QString &url)
        {
            return QFileInfo(url).isSymLink();
        }
        bool cpFile(const QString &source, const QString &target)
        {
            QFileInfo srcFileInfo(source);
            if (srcFileInfo.isDir()) {
                QDir targetDir(target);
                if (!targetDir.isRoot()) targetDir.cdUp();
                if (!targetDir.mkdir(QFileInfo(target).fileName()))
                    return false;
                QDir sourceDir(source);
                QStringList fileNames = sourceDir.entryList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot | QDir::Hidden | QDir::System);
                foreach (const QString &fileName, fileNames) {
                    const QString newSrcFilePath
                            = source + QLatin1Char('/') + fileName;
                    const QString newTgtFilePath
                            = target + QLatin1Char('/') + fileName;
                    if (!copyFile(newSrcFilePath, newTgtFilePath))
                        return false;
                }
            }
            else return QFile(source).copy(target);
            return true;
        }
        bool copyFile(const QString &source, const QString &target) {
            connect(&watcher, SIGNAL(finished()), this, SLOT(cpFinished()));
            QFuture<bool> future = QtConcurrent::run(this, &FM::cpFile, source, target);
            watcher.setFuture(future);
            return true;
        }
        bool moveFile(const QString &source, const QString &target)
        {
            if (copyFile(source,target))
            {
                QFileInfo srcFileInfo(source);
                if (srcFileInfo.isDir()) { removeDir(source); }
                else remove(source);
                return true;
            }
            else return false;
        }
        bool renameFile(const QString &source, const QString &target)
        {
            return QFile(source).rename(target);
        }
        bool createDir(const QString &target)
        {
            QDir newDir;
            return newDir.mkdir(target);
        }
        bool chmod(const QString &path,
                              bool ownerRead, bool ownerWrite, bool ownerExecute,
                              bool groupRead, bool groupWrite, bool groupExecute,
                              bool othersRead, bool othersWrite, bool othersExecute)
        {
            QFile file(path);
            QFileDevice::Permissions p;
            if (ownerRead) p |= QFileDevice::ReadOwner;
            if (ownerWrite) p |= QFileDevice::WriteOwner;
            if (ownerExecute) p |= QFileDevice::ExeOwner;
            if (groupRead) p |= QFileDevice::ReadGroup;
            if (groupWrite) p |= QFileDevice::WriteGroup;
            if (groupExecute) p |= QFileDevice::ExeGroup;
            if (othersRead) p |= QFileDevice::ReadOther;
            if (othersWrite) p |= QFileDevice::WriteOther;
            if (othersExecute) p |= QFileDevice::ExeOther;
            if (!file.setPermissions(p))
                return false;

            return true;
        }
        int getSize(const QString &url)
        {
            return QFileInfo(url).size();
        }
        int getDirSize(const QString &url)
        {
            connect(&dirWatcher, SIGNAL(finished()), this, SLOT(dirSizeFinished()));
            QFuture<quint64> future = QtConcurrent::run(this, &FM::_getDirSize,url);
            dirWatcher.setFuture(future);
            return -1;
        }
        quint64 _getDirSize(const QString &url)
        {
            quint64 sizex = 0;
            QFileInfo url_info(url);
            if (url_info.isDir())
            {
                QDir dir(url);
                QFileInfoList list = dir.entryInfoList(QDir::Files | QDir::Dirs |  QDir::Hidden | QDir::NoSymLinks | QDir::NoDotAndDotDot);
                for (int i = 0; i < list.size(); ++i)
                {
                    QFileInfo fileInfo = list.at(i);
                    if(fileInfo.isDir())
                    {
                            sizex += _getDirSize(fileInfo.absoluteFilePath());
                    }
                    else
                        sizex += fileInfo.size();

                }
            }
            return sizex;
        }
        QString getSymLinkTarget(const QString &url)
        {
            return QFileInfo(url).symLinkTarget();
        }
        QString getPermissions(const QString &url)
        {
            QFile::Permissions permissions;
            permissions = QFileInfo(url).permissions();
            char str[] = "---------";
            int oc = 0;
            if (permissions & 0x4000) { str[0] = 'r'; oc += 400; }
            if (permissions & 0x2000) { str[1] = 'w'; oc += 200; }
            if (permissions & 0x1000) { str[2] = 'x'; oc += 100; }
            if (permissions & 0x0040) { str[3] = 'r'; oc += 40; }
            if (permissions & 0x0020) { str[4] = 'w'; oc += 20; }
            if (permissions & 0x0010) { str[5] = 'x'; oc += 10; }
            if (permissions & 0x0004) { str[6] = 'r'; oc += 4; }
            if (permissions & 0x0002) { str[7] = 'w'; oc += 2; }
            if (permissions & 0x0001) { str[8] = 'x'; oc += 1; }
            return QString::fromLatin1(str) + " (" + QString::number(oc) + ")";
        }
        QString getOwner(const QString &url)
        {
            return QFileInfo(url).owner();
        }
        QString getGroup(const QString &url)
        {
            return QFileInfo(url).group();
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
        void cpFinished()
        {
           m_cpResult = watcher.future().result();
           qDebug() << "m_cpResult = " << m_cpResult;
           emit cpResultChanged();
        }
        void dirSizeFinished()
        {
           m_dirSize = dirWatcher.future().result();
           //qDebug() << "m_dirSize = " << m_dirSize;
           emit dirSizeChanged(m_dirSize);
        }
};


#endif // FMHELPER_HPP
