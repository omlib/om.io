package om.io;

#if (sys||nodejs)
import sys.FileSystem;
import sys.io.File;
#end

#if nodejs
//import js.Error;
//import js.node.Fs;
#end

using StringTools;
using haxe.io.Path;

/**
	File system helpers.
*/
class FileUtil {

	/**
		Returns the relative path to the given absolute path.
	*/
	public static function getRelativePath( absolutePath : String, ?cwd : String ) : String {
		if( cwd == null ) cwd = Sys.getCwd();
		if( absolutePath.startsWith( '/' ) ) absolutePath = absolutePath.substr(1);
		absolutePath = absolutePath.removeTrailingSlashes();
		if( cwd.startsWith( '/' ) ) cwd = cwd.substr(1);
		cwd = cwd.removeTrailingSlashes();
		var aParts = absolutePath.split( '/' );
		var cParts = cwd.split( '/' );
		var i = 0;
		while( i < aParts.length ) {
			if( aParts[i] != cParts[i] ) break else i++;
		}
		var n = cParts.length - i;
		var path = aParts.slice( i );
		for( i in 0...n ) path.unshift(  '..' );
		return path.join('/');
	}

	/**
	*/
	public static inline function size( path : String ) : Int {
		return FileSystem.stat( path ).size;
	}

	/**
	*/
	public static inline function modTime( path : String ) : Float {
		return FileSystem.stat( path ).mtime.getTime();
	}

	/**
	*/
	public static function deleteDirectory( path : String, recursive = true ) {
		//if( !FileSystem.exists( path ) )
		//	return;
		for( f in FileSystem.readDirectory( path ) ) {
			var fp = '$path/$f';
			if( FileSystem.isDirectory( fp ) ) {
				if( recursive ) deleteDirectory( fp, recursive );
			} else {
				FileSystem.deleteFile( fp );
			}
		}
		FileSystem.deleteDirectory( path );
	}

	/**
	*/
	public static function directoryExistsOrCreate( path : String ) : Bool {
		if( !FileSystem.exists( path ) ) {
			FileSystem.createDirectory( path );
			return true;
		}
		#if dev
		else if( !FileSystem.isDirectory( path ) )
			Console.warn( 'Not a directory [$path]' );
		#end
		return false;
	}

	/**
	*/
	public static function readTextContents( path : String ) : String {
		var buf = new StringBuf();
		for( f in FileSystem.readDirectory( path ) )
			buf.add( File.getContent( '$path/$f' ) );
		return buf.toString();
	}

	////////////////////////////////////////////////////////////////////////////

	#if nodejs

	/*
	public static function deleteDirectorySync( path : String, recursive = true ) {
        for( f in Fs.readdirSync( path ) ) {
            var p = '$path/$f';
            if( Fs.lstatSync( p ).isDirectory() ) {
				if( recursive ) deleteDirectorySync( p, recursive );
			} else Fs.unlinkSync( p );
        }
        Fs.rmdirSync( path );
    }

	public static function directoryExistsOrCreate( path : String, ?cb : Bool->Void ) {
		exists( path, function(yes){
			yes ? cb( true ) : Fs.mkdir( path, function(e) cb( false ) );
		});
	}

	public static function directoryExistsOrCreateSync( path : String ) : Bool {
		if( exists( path ) )
			return true;
		Fs.mkdirSync( path );
		return false;
	}
	*/

	///// Async

	/*
	public static inline function exists( path : String, callback : Bool->Void ) {
		Fs.access( path, function(e) callback( e == null ) );
	}

	public static inline function isDirectory( path : String, callback : Bool->Void ) {
		Fs.stat( path, function(e,stats) {
			(e != null) ? callback( false ) : callback( stats.isDirectory() );
		});
	}
	*/

	/*

	//TODO holy crap!

	public static function deleteDirectory( path : String, recursive = true, ?callback : Error->Void ) {
		isDirectory( path, function(yes){
			if( yes ) {
				_deleteDirectory( path, callback );
			} else {
				if( callback != null ) callback( new Error( 'not exists' ) );
			}
		});
	}

	static function _deleteDirectory( path : String, ?callback : Error->Void ) {
		Fs.readdir( path, function(e,entries) {
			if( e != null ) {
				if( callback != null ) callback(e);
				return;
			} else {
				_deleteDirectoryEntries( path, entries, callback );
			}
		});
	}

	static function _deleteDirectoryEntries( path : String, entries : Array<String>, ?callback : Error->Void ) {
		trace("_deleteDirectoryEntries "+path+ " : "+entries.length);
		if( entries.length == 0 ) {
			if( callback != null ) callback( null );
		} else {
			var p = path+'/'+entries.pop();
			trace(p);
			isDirectory( p, function(yes){
				if( yes ) {
					trace(entries.length);
					if( entries.length == 0 ) {
						Fs.rmdir( p, function(e){
							if( e != null ) {
								if( callback != null ) callback( e );
							} else {
								if( callback != null ) callback( null );
							}
						});
					} else {
						Fs.readdir( p, function(e,entries){
							if( e != null ) {
								if( callback != null ) callback( e );
								return;
							} else {
								_deleteDirectoryEntries( p, entries, callback );
							}
						});
					}
				} else {
					Fs.unlink( p, function(e){
						if( e != null ) {
							if( callback != null ) callback( e );
							return;
						}
					});
				}
			});
		}
	}
	*/

	///// Sync

	/*
	public static function existsSync( path : String ) : Bool {
		return try { Fs.accessSync(path); true; } catch (_:Dynamic) false;
	}

	public static inline function isDirectorySync( path : String ) : Bool {
		return Fs.statSync( path ).isDirectory();
	}

	public static inline function readDirectorySync( path : String ) : Array<String> {
		return Fs.readdirSync( path );
	}

	public static function deleteDirectorySync( path : String, recursive = true ) {
		for( f in FileSystem.readDirectory( path ) ) {
			var fp = '$path/$f';
			if( FileSystem.isDirectory( fp ) ) {
				if( recursive ) deleteDirectorySync( fp, recursive );
			} else {
				FileSystem.deleteFile( fp );
			}
		}
		FileSystem.deleteDirectory( path );
	}

	public static inline function modTimeSync( path : String ) : Float {
		return Fs.statSync( path ).mtime.getTime();
	}
	*/

	/*
	public static function copyFile( src : String, dst : String ) {
		Fs.createReadStream( src ).pipe( Fs.createWriteStream( dst ) );
	}
	*/



	#end

}
