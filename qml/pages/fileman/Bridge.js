var os = cutes.require('os');
var util = cutes.require('util');
var debug = cutes.require('debug');

var actor_ = undefined;

var dump_error = function(e) {
    debug.error(util.dump("Actor error event", e));
};

var init_actor = function(is_reload) {
    if (actor_ === undefined) {
        actor_ = cutes.actor();
        actor_.error.connect(dump_error);
        actor_.source = "Browser.js";
        is_reload = false;
    };
    if (is_reload)
        actor_.reload();
};

var actor = function() {
    init_actor();
    return actor_;
};

var special_paths_ = {
    "/proc" : null,
    "/sys" : null,
    "/config" : null,
    "/dev" : null
};

function isSpecialPath(path) {
    return (path in special_paths_);
}

function path() {
    return os.path.apply(null, [].slice.call(arguments));
}

function fileInfo(path) {
    return os.qt.fileInfo(path);
}

function listDir(data, ctx) {
    if (!(ctx.on_done && ctx.on_progress)) {
        console.log("listDir: absent ctx.done || progress");
        return;
    }
    actor().request('listDir', data
                    , {on_done: ctx.on_done
                       , on_error: ctx.on_error
                       , on_progress: ctx.on_progress});
}

function dirStack(path, ctx) {
    if (!(ctx.done)) {
        console.log(": absent ctx.done");
        return;
    }
    actor().request('dirStack', path
                  , {on_done: ctx.done, on_error: ctx.error
                     , on_progress: ctx.progress});
}

function pathStore(data) {
    if (!(data.path && data.name)) {
        console.log("pathStore needs path and name");
    }
    actor().request('pathStore', data, function() {
        console.log("Stored path ", data.path, data.name);
    });
}

function pathRecall(get) {
    actor().request('pathRecall', {}, function(paths) {
        util.forEach(paths, get);
    });
}

function getFileType(fileName, fileType, fn) {
    actor().request('getFileType', {fileType: fileType, fileName : fileName}, fn);
}
function waitOperationCompleted() {
    actor().wait();
}

function copy(src, dst, on_done) {
    actor().request('copy', {destination: dst, source: src}, on_done);
}

function rm(target) {
    actor().request('rm', {target: target}, function() {
        console.log("Removed ", target);
    });
}

function forEach(arr, fn) {
    util.forEach(arr, fn);
}

function getRoot() {
    return os.root();
}

function getHome() {
    return os.home();
}
