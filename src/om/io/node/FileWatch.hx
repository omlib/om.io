package om.io.node;

import js.node.Fs;
import js.node.fs.FSWatcher;
import haxe.crypto.Md5;
import haxe.ds.StringMap;

using Lambda;
using haxe.io.Path;
using om.io.FileUtil;

typedef FileWatchOptions = {
    @:optional var persistent : Bool;
}

typedef DirectoryWatchOptions = { > FileWatchOptions,
    @:optional var recursive : Bool;
    @:optional var whitelist : Array<String>;
    @:optional var blacklist : Array<String>;
}

enum FileSystemEventType {
    //create;
    //delete;
    rename;
    modify;
    //append;
}

typedef FileSystemEvent = {
    //var type : String;
    var type : FileSystemEventType;
    var path : String;
    var isDirectory : Bool;
}

/**
    Watches and reports changes on given filesystem path.

    It uses a md5-sum map to compare if files have changed for real since the nodejs implementation of fs.watch is that shitty and reports every event twice.
*/
@:require(nodejs)
class FileWatch {

    //public var active(default,null) : Bool;
    //public var paths(default,null) : Array<String>;
    public var numWatches(get,null) : Int;

    var watches : Array<FSWatcher>;
    var sums : StringMap<String>;

    public function new() {
        //active = false;
        //paths = [];
        watches = [];
        sums = new StringMap();
    }

    inline function get_numWatches() : Int return watches.length;

    public function dispose() {
        //active = false;
        for( watch in watches ) watch.close();
        watches = [];
        sums = new StringMap();
    }

    public function watchFile( path : String, ?options : FileWatchOptions, callback : FileSystemEvent->Void ) {
        _watchFile( path, cast options, callback );
    }

    public function watchDirectory( path : String, ?options : DirectoryWatchOptions, callback : FileSystemEvent->Void ) {
        _watchDirectory( path, options, callback );
    }

    function _watchFile( path : String, options : { ?persistent:Bool, ?whitelist:Array<String>, ?blacklist:Array<String> }, callback : FileSystemEvent->Void ) {
        watches.push(
            Fs.watch( path, function(e,f) { //TODO options
                if( options != null && !filter( f, options ) ) {
                    var type = (e == 'rename') ? rename : modify;
                    if( path.existsSync() ) {
                        var sum = md5( path );
                        if( sums.exists( path ) ) {
                            if( sums.get( path ) != sum ) {
                                sums.set( path, sum );
                                callback( { type:type, path:path, isDirectory:false } );
                            }
                        } else {
                            sums.set( path, sum );
                            callback( { type:type, path:path, isDirectory:false } );
                        }
                    } else {
                        callback( { type:type, path:path, isDirectory:false } );
                    }
                }
            })
        );
    }

    function _watchDirectory( path : String, ?options : DirectoryWatchOptions, callback : FileSystemEvent->Void ) {
        for( f in path.readDirectorySync() ) {
            var p = '$path/$f';
            if( p.isDirectorySync() ) {
                watches.push(
                    Fs.watch( p, {persistent:true,recursive:false}, function(e,f){
                        if( options != null && !filter( f, options ) ) {
                            var fp = '$p/$f';
                            var type = (e == 'rename') ? rename : modify;
                            if( fp.existsSync() ) {
                                /*
                                if( p.isDirectorySync() ) {
                                    callback( { type: e, path: p, isDirectory: true } );
                                }
                                */
                                callback( { type:type, path: fp, isDirectory: true } );
                            } else {
                                callback( { type:type, path: p, isDirectory: true } );
                            }
                        }
                    })
                );
                _watchDirectory( p, options, callback );
            } else {
                _watchFile( p, options, callback );
            }
        }
    }

    static function filter( path : String, filters : { ?whitelist:Array<String>, ?blacklist:Array<String> } ) : Bool {
        if( filters.blacklist != null ) {
            if( filtersMatch( path, filters.blacklist ) )
                return true;
        }
        if( filters.whitelist != null ) {
            return !filtersMatch( path, filters.whitelist );
        }
        return false;
    }

    static function filtersMatch( path : String, filters : Array<String> ) : Bool {
        for( exp in filters ) {
            var f = new EReg( exp, '' );
            if( f.match( path.withoutDirectory() ) ) {
                return true;
            }
        }
        return false;
    }

    static function md5( path : String ) : String {
        return Md5.encode( Fs.readFileSync( path, {encoding:'utf8'} ) );
    }
}
