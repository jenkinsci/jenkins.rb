
class DirectoryStructure
  def initialize(structure)
    context = DirChild.new('.')

    structure.each_line do |line|
      if line =~ /^(\[\-+\]|\ \|\ )\s+(.+)$/
        op, name = $1, $2
        child = case op
                when "[+]"
                  DirChild.new name
                when "[-]"
                  # TODO: make to tree structure
                  DirChild.new name
                when " | "
                  FileChild.new name
                end
        context.add child
      end
    end

    @root = context
  end

  def matches?(dir)
    @root.matches?(dir)
  end

  Entry = Struct.new(:name)

  class DirChild < Entry
    attr_accessor :entries

    def initialize(name)
      super(name)
      @entries = []
    end

    def add(entry)
      @entries << entry
    end

    def matches?(realdir)
      real_entries = Dir.glob(realdir + '/**/*').map{|e| File.basename(e) }
      (@entries.map(&:name) <=> real_entries) < 1
    end
  end

  class FileChild < Entry
  end
end
