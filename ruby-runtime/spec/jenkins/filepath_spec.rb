require 'spec_helper'

describe Jenkins::FilePath do
  include SpecHelper

  def create(str)
    native = Java.hudson.FilePath.new(Java.java.io.File.new(str))
    Jenkins::FilePath.new(native)
  end

  it "can be instantiated" do
    Jenkins::FilePath.new(double(Java.hudson.FilePath))
  end

  it "returns child for +" do
    expect((create(".") + "foo").to_s).to eq("foo")
    expect((create(".") + "foo" + "bar").to_s).to eq("foo/bar")
  end

  it "returns child for join" do
    expect(create('.').join('foo').to_s).to eq("foo")
    expect(create('.').join('foo', 'bar').to_s).to eq("foo/bar")
    expect(create('.').join('foo', 'bar', 'baz').to_s).to eq("foo/bar/baz")
  end

  it "returns path for to_s" do
    expect(create(".").to_s).to eq(".")
  end

  it "returns realpath" do
    expect(create(".").realpath).to match /\A\//
  end

  it "reads file" do
    expect(create(__FILE__).read).to match /MATCH EXACTLY THIS REGEX STRING IN FILE/
  end

  it "returns Time as mtime" do
    expect(create(__FILE__).mtime).to be_an_instance_of Time
  end

  it "returns stat" do
    stat = create(__FILE__).stat
    rstat = File.stat(__FILE__)
    expect(stat.size).to eq(rstat.size)
    expect(stat.mode).to eq(rstat.mode)
    expect(stat.mtime).to eq(rstat.mtime)
  end

  it "returns basename" do
    expect(create(__FILE__).basename).to be_an_instance_of Jenkins::FilePath
    expect(create(__FILE__).basename.to_s).to eq(__FILE__.split("/").last)
  end

  it "checks existence" do
    expect(create(".").exist?).to eq(true)
    expect(create("__NOSUCHFILE__").exist?).to eq(false)
  end

  it "checks directory or not" do
    expect(create(".").directory?).to eq(true)
    expect(create(__FILE__).directory?).to eq(false)
  end

  it "checks file or not" do
    expect(create(".").file?).to eq(false)
    expect(create(__FILE__).file?).to eq(true)
  end

  it "returns size" do
    expect(create(__FILE__).size).to eq(File.size(__FILE__))
  end

  it "returns entries in directory" do
    create(".").entries.each do |e|
      expect(e).to be_an_instance_of Jenkins::FilePath
    end
  end

  it "iterates entries in directory" do
    create(".").each_entry do |e|
      expect(e).to be_an_instance_of Jenkins::FilePath
    end
  end

  it "returns parent directory" do
    expect(create("/").parent.to_s).to eq("/")
    expect(create(".").parent.to_s).to eq("..")
    expect(create(".").parent.parent.to_s).to eq("../..")
    expect(create(__FILE__).parent.to_s).to eq(File.dirname(__FILE__))
  end

  it "can touch the file" do
    mktmpdir do |dir|
      t = Time.now
      (create(dir) + "foo").touch(t)
      expect((create(dir) + "foo").mtime.to_i).to eq(t.to_i)
    end
  end

  it "can check remote or not" do
    expect(create(".").remote?).to eq(false)
  end

  it "can create directory" do
    mktmpdir do |dir|
      (create(dir) + "foo").mkdir
      expect(create(File.join(dir, "foo")).exist?).to eq(true)
      expect(create(File.join(dir, "foo")).directory?).to eq(true)
    end
  end

  it "can delete file" do
    mktmpdir do |dir|
      (create(dir) + "foo").touch(Time.now)
      (create(dir) + "foo").delete
      expect(create(File.join(dir, "foo")).exist?).to eq(false)
    end
  end

  it "can delete directory" do
    mktmpdir do |dir|
      (create(dir) + "foo").mkdir
      (create(dir) + "foo").rmtree
      expect(create(File.join(dir, "foo")).exist?).to eq(false)
    end
  end
end

