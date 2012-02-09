
class DirectoryStructure
  def initialize(structure)

    @root = context = DirChild.new('.')

    structure.each_line do |line|
      if line =~ /(\[[-+]\]|\|)?\s+(\.?\w+)$/
        op, name = $1, $2
        case op
        when "[+]"
          context.add(DirChild.new name)
        when "[-]"
          new_context = DirChild.new name
          context.add(new_context)
          context = new_context
        when "|"
          context.add(FileChild.new name)
        end
      end
    end
  end

  def matches?(dir)
    @root.matches?(dir)
  end

  Entry = Struct.new(:name)

  class DirChild < Entry
    def initialize(name)
      super(name)
      @entries = []
    end

    def add(entry)
      @entries << entries
    end

    def matches?(realdir)
      entries = Dir.new(realdir).entries
      !@entries.detect {|e| !entries.map{|e| File.basename(e)}.member?(e)}
    end
  end

  class FileChild < Entry

  end
end