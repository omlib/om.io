package om.io;

#if sys

class Fifo {

	/**
        Create named pipe (FIFO).

        See: http://www.gnu.org/software/coreutils/mkfifoq

		mkfifo() makes a FIFO special file with name pathname. mode specifies the FIFO's permissions.
		It is modified by the process's umask in the usual way: the permissions of the created file are (mode & ~umask).

		A FIFO special file is similar to a pipe, except that it is created in a different way.
		Instead of being an anonymous communications channel, a FIFO special file is entered into the file system by calling mkfifo().

		Once you have created a FIFO special file in this way, any process can open it for reading or writing, in the same way as an ordinary file.

		However, it has to be open at both ends simultaneously before you can proceed to do any input or output operations on it.
		Opening a FIFO for reading normally blocks until some other process opens the same FIFO for writing, and vice versa.
	*/
	public static inline function mkfifo( path : String ) {
		Sys.command( 'mkfifo', [path] );
	}

}

#end
