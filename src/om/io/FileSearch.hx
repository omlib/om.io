package om.io;

class FileSearch {

    #if sys

    public static inline function find( path : String, name : String, maxDepth = -1 ) : Array<String> {
        return _find( path, name, [], maxDepth, 0 );
    }

    static function _find( path : String, name : String, found : Array<String>, maxDepth : Int, depth : Int ) : Array<String> {
        for( f in sys.FileSystem.readDirectory( path ) ) {
            var p = path + '/' + f;
            if( sys.FileSystem.isDirectory( p ) ) {
                if( maxDepth > 0 && ++depth == maxDepth )
                    break;
                else
                    _find( p, name, found, depth, maxDepth );
            } else if( f == name )
                found.push( p );
        }
        return found;
    }

    #end
}
