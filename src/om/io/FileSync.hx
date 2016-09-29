package om.io;

import sys.FileSystem;
import sys.FileSystem.exists;
import sys.FileSystem.isDirectory;
import sys.FileSystem.createDirectory;
import sys.FileSystem.readDirectory;
import sys.io.File;
import sys.io.File.copy;

using haxe.io.Path;
using om.io.FileUtil;

/**
	Utility to synchronize files and directories.
*/
class FileSync {

	/**
		Returns true if destination file doesn't exist or is older as source file.
	*/
	public static function needsUpdate( src : String, dst : String ) : Bool {
		return exists( dst ) ? src.modTime() > dst.modTime() : true;
	}

	/**
		Copies source file to target destination only if:
			* It exists
			* It is a file (not a directory)
			* It is newer as the file at destination

		Returns true if synced.
	*/
	public static function syncFile( src : String, dst : String ) : Bool {
		if( !exists( src ) || isDirectory( src ) || !needsUpdate( src, dst ) )
			return false;
		var dir = dst.directory();
		if( !exists( dir ) ) createDirectory( dir );
		copy( src, dst );
		return true;
	}

	/**
		Synchronizes directory.
	*/
	public static function syncDirectory( src : String, dst : String, recursive = true ) : Bool {
		if( !exists( src ) )
			return false;
			//throw 'Source directory not found : $src';
		if( !exists( dst ) )
			createDirectory( dst );
		for( f in readDirectory( src ) ) {
			var sp = '$src/$f';
			var dp = '$dst/$f';
			if( isDirectory( sp ) ) {
				//if( !exists( dst ) ) createDirectory( dst );
				if( recursive ) syncDirectory( sp, dp );
			} else {
				if( exists( dp ) ) {
					if( needsUpdate( sp, dp ) ) copy( sp, dp );
				} else {
					copy( sp, dp );
				}
			}
		}
		return true;
	}
}
