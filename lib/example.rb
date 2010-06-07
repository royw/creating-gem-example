# not the best solution, probably should use require_relative in ruby 1.9 or the backported
# version from Programming Ruby v3 for ruby 1.8.
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# a few of the gems I use in most projects
require 'rubygems'
require 'extlib'
require 'versionomy'
require 'log4r'
require 'configliere'
require 'singleton'
require 'pp'

# require all of the library files
# note, you may need to specify these explicitly if there are any load order dependencies
Dir[File.dirname(__FILE__) / 'example/**/*.rb'].each do |name| 
  require name
end

