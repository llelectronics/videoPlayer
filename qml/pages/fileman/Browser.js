var os = require('os');
var util = require('util');
var Q = require('qtcore');
var dirObj =  os.qt.dir;
var error = require('error');
var curDir;
var curList = [];
var sendFn;
var filters = Q.Dir.AllEntries | Q.Dir.NoDotAndDotDot;
var debug = require('debug');

var send_info = function(ctx, info) {
    var t = (info.isDir()
            ? 'd' : (info.isSymLink()
                    ? 's' : 'f'));
    var res = {name: info.fileName()
              , type: t
              , size: info.size()
              , exec: info.isExecutable()};
    ctx.reply(res);
};

var send_top_info = function(ctx, info) {
    var fname = info.fileName();
    if (fname === '.' || fname === '..')
        return;

    send_info(ctx, info);
};


exports.listDir = function(msg, ctx) {
    var dirName, begin, end, len, i;

    dirName = msg.dir;
    // static state is saved now for simplicity, so mixing requests
    // for several directories will cause mess
    if (!curDir || dirName !== curDir.path() || msg.refresh) {
        curDir = dirObj(dirName);
        sendFn = send_info;//curDir.isRoot() ? send_top_info : send_info;
        curList = curDir.entryInfoList(["*"], filters);
    }
    len = curList.length;
    begin = msg.begin || 0;
    end = msg.len ? Math.min(begin + msg.len, len) : len;
    if (begin > end)
        error.raise({msg: "Incorrect listDir params", begin: begin, end: end });

    for (i = begin; i < end; ++i)
        sendFn(ctx, curList[i]);

    return (end === len) ? false : {begin: end, len: len - end};
};

exports.dirStack = function(msg, ctx) {
    var d = os.path.canonical(msg);
    var res = d.split('/');
    var len  = res.length;
    if (len && res[res.length - 1] === '')
        res.pop();

    return res;
}

var pathsMemory = [];

// msg = info = {path, name} || [info,..]
exports.pathStore = function(msg, ctx) {
    if (typeof msg === 'array')
        pathsMemory = pathsMemory.concat(msg);
    else
        pathsMemory.push(msg);
};

exports.pathRecall = function(msg, ctx) {
    return pathsMemory;
};

exports.getFileType = function(msg, ctx) {
    var fileName = msg.fileName;
    var fileType = msg.fileType;
    if (fileName === "")
        return "";
    
    var os = cutes.require('os');
    var ps = cutes.require('subprocess');
    var fullName = fileName;
    if (fileType === 's') {
        var fi = Util.fileInfo(fullName);
        return '-> ' + fi.symLinkTarget();
    }
    
    cutes.require('util');
    var info = ps.check_output('file', [fullName]).toString();
    
    info = info.trim();
    info = info.split(":")[1];
    return info;//info.replace(/,/g, '\n');
};

exports.copy = function(msg, ctx) {
    var dst = msg.destination;
    var src = msg.source;
    if (!os.path.exists(dst))
        error.raise({msg: "Destination path does not exist:" + dst});
    if (!os.path.isDir(dst))
        error.raise({msg: "Destination is not directory:" + dst});
    if (!os.path.exists(src))
        error.raise({msg: "Source path does not exist" + src});
    os.treeCopy(src, dst);
};

exports.rm = function(msg, ctx) {
    var target = msg.target;
    if (!os.path.exists(target)) {
        debug.warning("Nothing to remove: ", target);
    }
    os.treeRemove(target);
};
