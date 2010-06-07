require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Example" do
  it "should return a Versionomy object as the version" do
    ver = Example.version
    ver.instance_of?(Versionomy::Value).should be_true
  end
  it "should return the version stored in the VERSION file" do
    v1 = Example.version.to_s.strip
    v2 = IO.read(File.expand_path(File.dirname(__FILE__) + "/../VERSION")).strip
    v1.should == v2
  end
end
