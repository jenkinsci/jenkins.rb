require 'pathname'

module Jenkins
  class FilePath
    include Jenkins::Plugin::Wrapper
    Stat = Struct.new(:size, :mode, :mtime)

    # Ruby's Pathname internace

    def +(name)
      FilePath.new(@native.child(name))
    end

    def join(*names)
      FilePath.new names.inject(@native) {|native, name| native.child(name) }
    end

    def to_s
      @native.getRemote()
    end

    def realpath
      @native.absolutize().getRemote()
    end

    def read(*args)
      @native.read.to_io.read(*args)
    end

    # TODO: atime jnr-posix?
    # TODO: ctime jnr-posix?

    def mtime
      Time.at(@native.lastModified().to_f / 1000)
    end

    def chmod(mask)
      @native.chmod(mask)
    end

    # TODO: chown
    # TODO: open

    def rename(to)
      @native.renameTo(create_filepath(to))
    end

    def stat
      Stat.new(size, @native.mode(), mtime)
    end

    # TODO: utime

    def basename
      FilePath.new(create_filepath(@native.getName()))
    end

    # TODO: dirname
    # TODO: extname

    def exist?
      @native.exists()
    end

    def directory?
      @native.isDirectory()
    end

    def file?
      !directory?
    end

    def size
      @native.length()
    end

    def entries
      @native.list().map { |native|
        FilePath.new(native)
      }
    end

    def mkdir
      @native.mkdirs
    end

    # TODO: rmdir
    # TODO: opendir

    def each_entry(&block)
      entries.each do |child|
        yield child
      end
    end

    def delete
      @native.delete()
    end
    alias unlink delete

    def rmtree
      @native.deleteRecursive()
    end

    # TODO: hudson.FilePath does not handle FilePath(".").parent since it scans
    # the last "/" for file, the 2nd last "/" for directory. Can Jenkins handle
    # new FilePatn(ch, "../..") correctly?
    def parent
      parent = Pathname.new(to_s).parent.to_s
      FilePath.new(Java.hudson.FilePath.new(@native.getChannel(), parent))
    end

    # Original interface

    def touch(time)
      @native.touch(time.to_i * 1000)
    end

    def remote?
      @native.isRemote()
    end

    # TODO: createTempDir
    # TODO: createTempFile

    def create_launcher(listener)
      Launcher.new(@native.createLauncher(listener.native))
    end

  private

    def create_filepath(path)
      Java.hudson.FilePath.new(@native.getChannel(), path)
    end
  end
end
