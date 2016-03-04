package om.io;

typedef FileWatch =
    #if nodejs om.io._node.FileWatch
    #elseif sys om.io._sys.FileWatch
    #end;
