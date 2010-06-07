class Example
  def self.version
    ver = Versionomy.parse(IO.read(File.expand_path(File.dirname(__FILE__) + "/../VERSION")).strip)
    ver
  end
  def execute
    Settings[:logger].debug "Example.execute"
  end
end
