module Jenkins
  class FilePath

    attr_reader :natvie

    def initialize(native)
      @native = native
    end

    # Ruby's Pathname internace

    def +(name)
      FilePath.new(@native.child(name))
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
    alias binread read

    # TODO: atime jnr-posix?
    # TODO: ctime jnr-posix?

    def mtime
      Time.at(@native.lastModified())
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
      # TODO: @native.mode()
      nil
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

    def parent
      FilePath.new(@native.getParent())
    end

    # Original interface

    def remote?
      @native.isRemote()
    end

    # TODO: createTempDir
    # TODO: createTempFile

  private

    def create_filepath(path)
      hudson.FilePath.new(@native.getChannel(), path)
    end
  end
end
