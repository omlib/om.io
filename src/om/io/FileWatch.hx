package om.io;

#if nodejs

import js.node.Fs;
import js.node.fs.FSWatcher;
import haxe.ds.StringMap;
import js.Promise;
import js.Error;
import om.crypto.MD5;

enum FileWatchEventType {
    //create;
    //delete;
    rename;
    modify;
    //append;
}

typedef FileWatchEvent = {
    //var type : String;
    var type : FileWatchEventType;
    var path : String;
    //var isDirectory : Bool;
}

//class FileWatchEvent {

class FileWatch {

	public var path(default,null) : String;

	var subsciption : FSWatcher;
	var sums : StringMap<String>;
	//var promise : Promise<FileWatchEvent>;

	public function new( path : String ) {
		this.path = path;
	}

	public function file( persistent = true ) : Promise<FileWatchEvent> {

		return new Promise(function(resolve,reject){

			Fs.access( path, function(e) {

				if( e != null ) reject(e) else {

					sums = new StringMap();

					subsciption = Fs.watch( path, { persistent: persistent }, function(change,path){

						trace(path+"::: "+change);

						var type = (change == 'rename') ? rename : modify;

						//resolve( { path: path, type: type } );
						//resolve( { path: path, type: type } );
						resolve( { path: path, type: type } );

						/*
						var sum = md5( path );
						if( sums.exists( path ) ) {
							if( sums.get( path ) != sum ) {
								sums.set( path, sum );
								resolve( { path: path, type: type } );
							}
						} else {
							sums.set( path, sum );
							resolve( { path: path, type: type } );
						}
						*/
					});
				}
			});
		});
	}

	/*
	public function file( handler : Error->FileWatchEvent->Void, persistent = true ) {

		Fs.access( path, function(e) {

			if( e != null ) handler(e,null) else {

				sums = new StringMap();

				subsciption = Fs.watch( path, { persistent: persistent }, function(change,path){

					trace(path+"::: "+change);

					var type = (change == 'rename') ? rename : modify;

					//resolve( { path: path, type: type } );
					handler( null,{ path: path, type: type } );
				});
			}
		});
	}

	*/

		/*

		var promise = new Promise(function(resolve,reject){

			Fs.access( path, function(e) {

				if( e != null ) reject(e) else {

					sums = new StringMap();

					subsciption = Fs.watch( path, { persistent: persistent }, function(change,path){

						trace(path+"::: "+change);

						var type = (change == 'rename') ? rename : modify;

						//resolve( { path: path, type: type } );
						resolve( { path: path, type: type } );
						resolve( { path: path, type: type } );
						resolve( { path: path, type: type } );

						/*
						var sum = md5( path );
						if( sums.exists( path ) ) {
							if( sums.get( path ) != sum ) {
								sums.set( path, sum );
								resolve( { path: path, type: type } );
							}
						} else {
							sums.set( path, sum );
							resolve( { path: path, type: type } );
						}
						* /
					});
				}
			});
		});

		return promise;
	}
	*/

	/*
	public function stop() {
		if( subsciption != null ) subsciption.close();
		sums = new StringMap();
	}
	*/

	/*
	function handleEvent( change : FSWatcherChangeType, path : FsPath ) {
		var type = (change == 'rename') ? rename : modify;
		var sum = md5( path );
		if( sums.exists( path ) ) {
			if( sums.get( path ) != sum ) {
				sums.set( path, sum );
				trace("::");
				promise = Promise.resolve( { path: path, type: type } );
			}
		} else {
			sums.set( path, sum );
			promise = Promise.resolve( { path: path, type: type } );
			trace("::aa");
		}
	}
	*/

	static function md5( path : String ) : String {
        //return MD5.encode( Fs.readFileSync( path, {encoding:'utf8'} ) );
        return MD5.encode( path );
    }
}

#end
