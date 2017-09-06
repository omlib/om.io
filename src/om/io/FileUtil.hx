package om.io;

import haxe.Json;

using StringTools;
using haxe.io.Path;

/**
	File system helpers.
*/
class FileUtil {

	public static inline function exists( path : String ) : Bool {

		#if sys
		return sys.FileSystem.exists( path );

		#elseif nodejs
		try js.node.Fs.accessSync(path) catch(_:Dynamic) {
			return false;
		}
		return true;

		#else
		return throw 'not implemented';

		#end
	}

	public static inline function count( dir : String ) : Int {
		return FileSystem.readDirectory( dir ).length;
	}

	public static inline function size( path : String ) : Int {
		return FileSystem.stat( path ).size;
	}

	public static inline function modTime( path : String ) : Float {
		return FileSystem.stat( path ).mtime.getTime();
	}

	public static function getLastModifiedFile( dir : String ) : String {
		var time = 0.0;
		var path : String = null;
		for( f in FileSystem.readDirectory( dir ) ) {
			var p = '$dir/$f';
			var fTime = modTime( p );
			if( fTime > time ) {
				time = fTime;
				path = f;
			}
		}
		return path;
	}

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

	public static inline function isEmpty( dir : String ) : Bool
		return count( dir ) == 0;

	public static function createDirectory( path : String ) {
		var parts = path.split( '/' );
		var current = '';
		for( part in parts ) {
			current += '$part/';
			if( !sys.FileSystem.exists( current ) )
				sys.FileSystem.createDirectory( current );
		}
	}

	public static inline function getXmlContent( path : String ) : Xml {
		return Xml.parse( sys.io.File.getContent( path ) ).firstElement();
	}

	public static inline function getJsonContent<T>( path : String ) : T {
		return Json.parse( sys.io.File.getContent( path ) );
	}

	public static function getTextContents( path : String ) : String {
		var buf = new StringBuf();
		for( f in FileSystem.readDirectory( path ) )
			buf.add( sys.io.File.getContent( '$path/$f' ) );
		return buf.toString();
	}

	public static inline function touch( path : String ) {

		#if (nodejs&&!macro)
		js.node.Fs.closeSync( js.node.Fs.openSync( path, 'w' ) );

		#elseif sys
		sys.io.File.write( path ).close();

		#end
	}

	public static inline function createTextFile( path : String, ?content : String ) {
		var dir = path.directory();
		if( FileSystem.exists( dir ) ) {
			if( FileSystem.exists( path ) )
				throw 'file exists: $path';
			writeTextFile( path );
		} else {
			createDirectory( dir );
			writeTextFile( path );
		}
	}

	public static inline function writeTextFile( path : String, ?content : String ) {

		#if (nodejs&&!macro)
		var f = js.node.Fs.openSync( path, 'w' );
		if( content != null ) js.node.Fs.writeSync( f, content );
		js.node.Fs.closeSync( f );

		#elseif sys
		var f = sys.io.File.write( path );
        if( content != null ) f.writeString( content );
        f.close();

		#end
	}

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

	public static function directoryExistsOrCreate( path : String ) : Bool {
		if( !FileSystem.exists( path ) ) {
			FileSystem.createDirectory( path );
			return true;
		}
		#if dev
		else if( !FileSystem.isDirectory( path ) )
			trace( 'Not a directory [$path]' );
		#end
		return false;
	}

	#if (!macro&&nodejs) ///////////////////////////////////////////////////////

	/*
	public static inline function exists( path : String, callback : Bool->Void ) {
		Fs.stat( path, function(e,_) callback( e == null ) );
	}

	public static inline function isDirectory( path : String, callback : Bool->Void ) {
		Fs.stat( path, function(e,s) (e != null) ? callback( null ) : callback( s.isDirectory() ) );
	}
	*/

	public static inline function readDirectorySync( path : String ) : Array<String> {
		return js.node.Fs.readdirSync( path );
	}

	public static inline function existsSync( path : String ) : Bool {
		return try { js.node.Fs.accessSync( path ); true; } catch (_:Dynamic) false;
	}

	public static inline function isDirectorySync( path : String ) : Bool {
		return js.node.Fs.statSync( path ).isDirectory();
	}

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

	#end // nodejs

}
