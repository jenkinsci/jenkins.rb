module Work
  def run cmd
    Dir.chdir(work_dir) do
      root = Pathname(__FILE__).join('..', '..', '..')
      full_cmd = "ruby -rubygems -I #{root.join('lib')} -S #{root.join('bin',cmd)}"
      system(full_cmd) or fail "failed to run command #{cmd}"
    end
  end

  def work_dir
    @work_dir ||= File.expand_path("tmp/work")
  end
end

Before do
  FileUtils.rm_rf work_dir
  FileUtils.mkdir_p work_dir
end

World(Work)