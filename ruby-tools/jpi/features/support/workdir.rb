module Work
  def work_dir
    @work_dir ||= File.expand_path("tmp/work")
  end
end

World(Work)

Before do
  FileUtils.rm_rf work_dir
  FileUtils.mkdir_p work_dir
  @dirs = [work_dir]
end

