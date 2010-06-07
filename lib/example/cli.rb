
# Command Line Interface to the Example application
#
# Usage:
#
#  exit CLI.execute
#
# Note, this is a Singleton class, only use CLI.execute to access this class.
#
class CLI
  include Singleton
  
  # The application can monitor this attribute to know if an interrupt (^c) has been signalled.
  attr_reader :interrupt_signalled
  
  APP_NAME = 'example'
  
  # The main entry point for the CLI
  # returns the exit code
  def self.execute
    instance.execute
  end

  # protected by the Singleton.  I.e., do not attempt CLI.new  
  def initialize
    @interrupt_signalled = false
  end
  
  # execute the app from the CLI
  # returns the exit code
  def execute
    exit_code = 0
    # ^c handler
    Signal.trap("INT") { @interrupt_signalled = true }
    begin
      setup_settings
      Settings[:app_name] = APP_NAME
      if Settings[:version]
        puts Example.version.to_s
      else
        Settings[:logger] = init_logger
        app = Example.new
        app.execute
      end
    rescue SystemExit
      # exit() calls from within the block actually raise SystemExit
    rescue Exception => e
      Settings[:logger].error e.to_s if Settings[:logger]
      exit_code = 1
    end
    exit_code
  end
  
  # log4r setup
  def init_logger
    # Initial setup of logger
    logger = Log4r::Logger.new(APP_NAME)
    level_map = {'DEBUG' => Log4r::DEBUG, 'INFO' => Log4r::INFO, 'WARN' => Log4r::WARN}
    
    # console messages
    logger.outputters = Log4r::StdoutOutputter.new(:console)
    Log4r::Outputter[:console].formatter  = Log4r::PatternFormatter.new(:pattern => "%m")
    Log4r::Outputter[:console].level = Log4r::INFO
    Log4r::Outputter[:console].level = Log4r::WARN if Settings[:quiet]
    Log4r::Outputter[:console].level = Log4r::DEBUG if Settings[:debug]
    Log4r::Outputter[:console].formatter = Log4r::PatternFormatter.new(:pattern => "%m")
    logger.trace = true if Settings[:trace]

    if Settings[:logfile]
      logfile_outputter = Log4r::RollingFileOutputter.new(:logfile, :filename => Settings[:logfile], :maxsize => 1000000 )
      logger.add logfile_outputter
      Settings[:loglevel] ||= 'INFO'
      Log4r::Outputter[:logfile].formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %d :: %M")
      Log4r::Outputter[:logfile].level = level_map[Settings[:loglevel].upcase] || Log4r::INFO
    end
    logger
  end
  
  # Configliere setup
  def setup_settings
    Settings.use :all
     
    Settings.define :logfile, :type => String, :description => 'Log filename, default is: media2nfo.log', :required => false
    Settings.define :loglevel, :type => String, :description => 'Logfile logging level, must be one of: DEBUG, INFO, WARN, ERROR', :required => false
    Settings.define :debug, :type => :boolean, :description => 'Log debug messages to console', :required => false
    Settings.define :quiet, :type => :boolean, :description => 'Only log errors to console', :required => false
    Settings.define :trace, :type => :boolean, :description => 'Trace logging', :required => false
    Settings.define :version, :type => :boolean, :description => 'Application Version', :required => false
     
    Settings({
              :logfile => "#{APP_NAME}.log",
              :loglevel => 'debug'
             })
             
    Settings.read("#{APP_NAME}.yaml") if File.exist?(File.expand_path("~/.configliere/#{APP_NAME}.yaml"))
    Settings.resolve!
  end
end
