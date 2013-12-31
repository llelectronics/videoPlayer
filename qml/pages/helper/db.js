//db.js
.import QtQuick.LocalStorage 2.0 as LS
// First, let's create a short helper function to get the database connection
function getDatabase() {
    return LS.LocalStorage.openDatabaseSync("LLsVideoPlayer", "0.1", "StorageDatabase", 100000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    // Create the history table if it doesn't already exist
                    // If the table exists, this is skipped
                    tx.executeSql('CREATE TABLE IF NOT EXISTS history(uid INTEGER UNIQUE, url TEXT)');
                    // Limit history entries to 10
                    tx.executeSql('CREATE TRIGGER IF NOT EXISTS delete_till_10 INSERT ON history WHEN (select count(*) from history)>9 \
BEGIN \
    DELETE FROM history WHERE history.uid IN (SELECT history.uid FROM history ORDER BY history.uid limit (select count(*) -10 from history)); \
END;')
                });
}

// This function is used to write history into the database
function addHistory(url) {
    var date = new Date();
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        // Remove and readd if url already in history
        var rs0 = tx.executeSql('delete from history where url=(?);',[url]);
        if (rs0.rowsAffected > 0) {
            console.debug("Url already found and removed to readd it");
        } else {
            console.debug("Url not found so add it newly");
        }

        var rs = tx.executeSql('INSERT OR REPLACE INTO history VALUES (?,?);', [date.getTime(),url]);
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

function showHistoryLast() {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        res = tx.executeSql('SELECT history.uid FROM history ORDER BY history.uid limit (select count(*) -10 from history);');
        for (var i = 0; i < res.rows.length; i++) {
            console.debug("showHistoryLast: " + res.rows.item(i).uid);
        }
    })
}

// This function is used to retrieve history from database
function getHistory() {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT history.url FROM history ORDER BY history.uid;');
        for (var i = 0; i < rs.rows.length; i++) {
            openUrlPage.addHistory(rs.rows.item(i).url)
            //console.debug("Get History urls:" + rs.rows.item(i).url)
        }
    })
}
