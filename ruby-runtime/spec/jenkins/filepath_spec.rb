require 'spec_helper'

describe Jenkins::FilePath do
  include SpecHelper

  def create(str)
    native = Java.hudson.FilePath.new(Java.java.io.File.new(str))
    Jenkins::FilePath.new(native)
  end

  it "can be instantiated" do
    Jenkins::FilePath.new(mock(Java.hudson.FilePath))
  end

  it "returns child for +" do
    (create(".") + "foo").to_s.should == "foo"
    (create(".") + "foo" + "bar").to_s.should == "foo/bar"
  end

  it "returns child for join" do
    create('.').join('foo').to_s.should == "foo"
    create('.').join('foo', 'bar').to_s.should == "foo/bar"
    create('.').join('foo', 'bar', 'baz').to_s.should == "foo/bar/baz"
  end

  it "returns path for to_s" do
    create(".").to_s.should == "."
  end

  it "returns realpath" do
    create(".").realpath.should match /\A\//
  end

  it "reads file" do
    create(__FILE__).read.should match /MATCH EXACTLY THIS REGEX STRING IN FILE/
  end

  it "returns Time as mtime" do
    create(__FILE__).mtime.should be_an_instance_of Time
  end

  it "returns stat" do
    stat = create(__FILE__).stat
    rstat = File.stat(__FILE__)
    stat.size.should == rstat.size
    stat.mode.should == rstat.mode
    stat.mtime.should == rstat.mtime
  end

  it "returns basename" do
    create(__FILE__).basename.should be_an_instance_of Jenkins::FilePath
    create(__FILE__).basename.to_s.should == __FILE__.split("/").last
  end

  it "checks existence" do
    create(".").exist?.should == true
    create("__NOSUCHFILE__").exist?.should == false
  end

  it "checks directory or not" do
    create(".").directory?.should == true
    create(__FILE__).directory?.should == false
  end

  it "checks file or not" do
    create(".").file?.should == false
    create(__FILE__).file?.should == true
  end

  it "returns size" do
    create(__FILE__).size.should == File.size(__FILE__)
  end

  it "returns entries in directory" do
    create(".").entries.each do |e|
      e.should be_an_instance_of Jenkins::FilePath
    end
  end

  it "iterates entries in directory" do
    create(".").each_entry do |e|
      e.should be_an_instance_of Jenkins::FilePath
    end
  end

  it "returns parent directory" do
    create("/").parent.to_s.should == "/"
    create(".").parent.to_s.should == ".."
    create(".").parent.parent.to_s.should == "../.."
    create(__FILE__).parent.to_s.should == File.dirname(__FILE__)
  end

  it "can touch the file" do
    mktmpdir do |dir|
      t = Time.now
      (create(dir) + "foo").touch(t)
      (create(dir) + "foo").mtime.to_i.should == t.to_i
    end
  end

  it "can check remote or not" do
    create(".").remote?.should == false
  end

  it "can create directory" do
    mktmpdir do |dir|
      (create(dir) + "foo").mkdir
      create(File.join(dir, "foo")).exist?.should == true
      create(File.join(dir, "foo")).directory?.should == true
    end
  end

  it "can delete file" do
    mktmpdir do |dir|
      (create(dir) + "foo").touch(Time.now)
      (create(dir) + "foo").delete
      create(File.join(dir, "foo")).exist?.should == false
    end
  end

  it "can delete directory" do
    mktmpdir do |dir|
      (create(dir) + "foo").mkdir
      (create(dir) + "foo").rmtree
      create(File.join(dir, "foo")).exist?.should == false
    end
  end
end

