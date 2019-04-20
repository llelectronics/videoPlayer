//db.js
.import QtQuick.LocalStorage 2.0 as LS
// First, let's create a short helper function to get the database connection
function getDatabase() {
    return LS.LocalStorage.openDatabaseSync("LLsVideoPlayer", "", "StorageDatabase", 100000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();
    if(db.version == '') {
        db.changeVersion('', '0.5', function(tx) {
            // Create the history table if it doesn't already exist
            // If the table exists, this is skipped
            tx.executeSql('CREATE TABLE IF NOT EXISTS history(uid INTEGER UNIQUE, url TEXT, title TEXT)');
            // Limit history entries to 10
            tx.executeSql('CREATE TRIGGER IF NOT EXISTS delete_till_10 INSERT ON history WHEN (select count(*) from history)>9 \
BEGIN \
    DELETE FROM history WHERE history.uid IN (SELECT history.uid FROM history ORDER BY history.uid limit (select count(*) -10 from history)); \
END;')

            tx.executeSql('CREATE TABLE IF NOT EXISTS bookmarks(title TEXT, url TEXT, liveStream INTEGER)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT, value TEXT)');
            tx.executeSql('CREATE UNIQUE INDEX IF NOT EXISTS idx_settings ON settings(setting)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS positionStore(uid INTEGER UNIQUE, url TEXT, position INTEGER)');
            // Limit positionStore entries to 10
            tx.executeSql('CREATE TRIGGER IF NOT EXISTS delete_pos_till_10 INSERT ON positionStore WHEN (select count(*) from positionStore)>9 \
BEGIN \
    DELETE FROM positionStore WHERE positionStore.uid IN (SELECT positionStore.uid FROM positionStore ORDER BY positionStore.uid limit (select count(*) -10 from positionStore)); \
END;')
            tx.executeSql('CREATE TABLE IF NOT EXISTS searchHistory(uid INTEGER UNIQUE, searchTerm TEXT)');
            // Limit history entries to 20
            tx.executeSql('CREATE TRIGGER IF NOT EXISTS delete_till_20 INSERT ON searchHistory WHEN (select count(*) from history)>19 \
BEGIN \
    DELETE FROM searchHistory WHERE searchHistory.uid IN (SELECT searchHistory.uid FROM searchHistory ORDER BY searchHistory.uid limit (select count(*) -20 from searchHistory)); \
END;')
        });
    }
    else if (db.version == '0.1') {
        // Need to upgrade History here
        db.changeVersion('0.1', '0.2', function(tx) {
            tx.executeSql('alter table history add title TEXT');
        });
    }
    else if (db.version == '0.2') {
        // Need to upgrade History here
        db.changeVersion('0.2', '0.3', function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS positionStore(uid INTEGER UNIQUE, url TEXT, position INTEGER)');
            // Limit positionStore entries to 10
            tx.executeSql('CREATE TRIGGER IF NOT EXISTS delete_pos_till_10 INSERT ON positionStore WHEN (select count(*) from positionStore)>9 \
BEGIN \
    DELETE FROM positionStore WHERE positionStore.uid IN (SELECT positionStore.uid FROM positionStore ORDER BY positionStore.uid limit (select count(*) -10 from positionStore)); \
END;')
        });
    }
    else if (db.version == '0.3') {
        db.changeVersion('0.3', '0.4', function(tx) {
            // Add Youtube Search History
            tx.executeSql('CREATE TABLE IF NOT EXISTS searchHistory(uid INTEGER UNIQUE, searchTerm TEXT)');
            // Limit history entries to 20
            tx.executeSql('CREATE TRIGGER IF NOT EXISTS delete_till_20 INSERT ON searchHistory WHEN (select count(*) from history)>19 \
BEGIN \
DELETE FROM searchHistory WHERE searchHistory.uid IN (SELECT searchHistory.uid FROM searchHistory ORDER BY searchHistory.uid limit (select count(*) -20 from searchHistory)); \
END;')
        });
    }
    else if (db.version == '0.4') {
        // Need to upgrade Bookmarks here
        db.changeVersion('0.4', '0.5', function(tx) {
            console.debug("Upgrading db and adding liveStream to db")
            tx.executeSql('alter table bookmarks add liveStream INTEGER');
        });
    }
}

// This function is used to write history into the database
function addHistory(url,title) {
    var date = new Date();
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        // Remove and readd if url already in history
        var rs0 = tx.executeSql('delete from history where url=(?);',[url]);
        if (rs0.rowsAffected > 0) {
            //console.debug("Url already found and removed to readd it");
        } else {
            //console.debug("Url not found so add it newly");
        }

        var rs = tx.executeSql('INSERT OR REPLACE INTO history VALUES (?,?,?);', [date.getTime(),url,title]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            //console.log ("Saved to database");
        } else {
            res = "Error";
            //console.log ("Error saving to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

function showHistoryLast() {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        res = tx.executeSql('SELECT history.uid FROM history ORDER BY history.uid limit (select count(*) -10 from history);');
        for (var i = 0; i < res.rows.length; i++) {
            //console.debug("showHistoryLast: " + res.rows.item(i).uid);
        }
    })
}

// This function is used to retrieve history from database
function getHistory() {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM history ORDER BY history.uid;');
        for (var i = 0; i < rs.rows.length; i++) {
            if (rs.rows.item(i).title != null) {
                //console.debug("[db.js] History text != '' :" + rs.rows.item(i).title);
                firstPage.addHistory(rs.rows.item(i).url,rs.rows.item(i).title)
            } else firstPage.addHistory(rs.rows.item(i).url,rs.rows.item(i).url)
        }
    })
}

// This function is used to write searchHistory into the database
function addSearchHistory(searchTerm) {
    var date = new Date();
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        // Remove and readd if url already in history
        var rs0 = tx.executeSql('delete from searchHistory where searchTerm=(?);',[searchTerm]);
        if (rs0.rowsAffected > 0) {
            //console.debug("Url already found and removed to readd it");
        } else {
            //console.debug("Url not found so add it newly");
        }

        var rs = tx.executeSql('INSERT OR REPLACE INTO searchHistory VALUES (?,?);', [date.getTime(),searchTerm]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            //console.log ("Saved to database");
        } else {
            res = "Error";
            //console.log ("Error saving to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to retrieve searchHistory from database
function getSearchHistory() {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM searchHistory ORDER BY searchHistory.uid;');
        for (var i = 0; i < rs.rows.length; i++) {
            if (rs.rows.item(i).searchTerm != null) {
                //console.debug("[db.js] SearchHistory term != '' :" + rs.rows.item(i).searchTerm);
                firstPage.addSearchHistory(rs.rows.item(i).searchTerm)
            }
        }
    })
}

// This function is used to write bookmarks into the database
function addBookmark(title,url,liveStream) {
    var db = getDatabase();
    var res = "";
    liveStream = liveStream ? 1 : 0
    db.transaction(function(tx) {
        // Remove and readd if url already in history
        removeBookmark(url);
        //console.debug("Adding to bookmarks db:" + title + " " + url);

        var rs = tx.executeSql('INSERT OR REPLACE INTO bookmarks VALUES (?,?,?);', [title,url,liveStream]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Saved to database");
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to edit bookmarks in the database
function editBookmark(oldtitle,title,url,liveStream) {
    var db = getDatabase();
    var res = "";
    liveStream = liveStream ? 1 : 0
    db.transaction(function(tx) {
        console.debug("UPDATE bookmarks SET title=" + title + ", url=" + url + " liveStream=" + liveStream + " WHERE title=" + oldtitle + ";")
        var rs = tx.executeSql('UPDATE bookmarks SET title=(?), url=(?), liveStream=(?) WHERE title=(?);', [title,url,liveStream,oldtitle]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Saved to database");
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to remove a bookmark from database
function removeBookmark(url) {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM bookmarks WHERE url=(?);', [url]);
//        if (rs.rowsAffected > 0) {
//            console.debug("Url found and removed");
//        } else {
//            console.debug("Url not found");
//        }
    })
}

// This function is used to retrieve bookmarks from database
function getBookmarks() {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM bookmarks ORDER BY bookmarks.title;');
        for (var i = 0; i < rs.rows.length; i++) {
            //console.debug("liveStream: " + rs.rows.item(i).liveStream)
            var liveStream = rs.rows.item(i).liveStream == 1 ? true : false
            mainWindow.modelBookmarks.append({"title" : rs.rows.item(i).title, "url" : rs.rows.item(i).url, "liveStream" : liveStream});
        }
    })
}

// This function is used to write position into the database
function addPosition(url,position) {
    var date = new Date();
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        // Remove and readd if url already in history
        var rs0 = tx.executeSql('delete from positionStore where url=(?);',[url]);
        if (rs0.rowsAffected > 0) {
            //console.debug("Url already found and removed to readd it");
        } else {
            //console.debug("Url not found so add it newly");
        }

        var rs = tx.executeSql('INSERT OR REPLACE INTO positionStore VALUES (?,?,?);', [date.getTime(),url,position]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            //console.log ("Saved to database");
        } else {
            res = "Error";
            //console.log ("Error saving to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to write position into the database
function getPosition(url) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT position FROM positionStore WHERE url=(?);', [url]);
    if (rs.rows.length > 0) {  // Headaches !!! Why isn't rowsAffected working here ?
        for (var i = 0; i < rs.rows.length; i++) {
            if (rs.rows.item(i).position != null) {
                //console.debug("[db.js] History text != '' :" + rs.rows.item(i).title);
                res = rs.rows.item(i).position
                return res;
            } else res = "Not Found";
        }
        } else {
            res = "Not Found";
            //console.log ("Error saving to database");
        }
    }
    );
    return res;
}

// This function is used to write settings into the database
function addSetting(setting,value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Setting written to database");
        } else {
            res = "Error";
            console.log ("Error writing setting to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

function stringToBoolean(str) {
    switch(str.toLowerCase()){
    case "true": case "yes": case "1": return true;
    case "false": case "no": case "0": case null: return false;
    default: return Boolean(string);
    }
}

function clearTable(table) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql("DELETE FROM " + table);
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Cleared database table " + table);
        } else {
            res = "Error";
            console.log ("Error clearing database table " + table);
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to retrieve settings from database
function getSettings() {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM settings;');
        for (var i = 0; i < rs.rows.length; i++) {
            if (rs.rows.item(i).setting == "enableSubtitles") mainWindow.firstPage.enableSubtitles = stringToBoolean(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "subtitlesSize") mainWindow.firstPage.subtitlesSize = rs.rows.item(i).value
            else if (rs.rows.item(i).setting == "boldSubtitles") mainWindow.firstPage.boldSubtitles = stringToBoolean(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "subtitlesColor") mainWindow.firstPage.subtitlesColor = rs.rows.item(i).value
            //else if (rs.rows.item(i).setting == "youtubeDirect") mainWindow.firstPage.youtubeDirect = stringToBoolean(rs.rows.item(i).value) // awlays on as ytapi changed api and wants money
            else if (rs.rows.item(i).setting == "openDialogType") mainWindow.firstPage.openDialogType = rs.rows.item(i).value
            else if (rs.rows.item(i).setting == "liveView") mainWindow.firstPage.liveView = stringToBoolean(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "subtitleSolid") mainWindow.firstPage.subtitleSolid = stringToBoolean(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "ytDefaultQual") mainWindow.firstPage.ytQualWanted = rs.rows.item(i).value
            else if (rs.rows.item(i).setting == "onlyMusicState") mainWindow.firstPage.onlyMusicState = rs.rows.item(i).value
            else if (rs.rows.item(i).setting == "clearWebViewOnExit") mainWindow.clearWebViewOnExit = stringToBoolean(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "alwaysYtdl") mainWindow.firstPage.alwaysYtdl = stringToBoolean(rs.rows.item(i).value)
        }
    })
}
