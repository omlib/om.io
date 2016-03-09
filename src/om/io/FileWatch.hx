package om.io;

typedef FileWatch =
    #if nodejs om.io.node.FileWatch
    #elseif sys om.io.sys.FileWatch
    #end;
