require 'sinatra'
require 'sanitize'
require 'carmen'
require 'curb'
require 'json'
require 'yaml'
require 'securerandom'

Dir.glob( File.expand_path('lib/*.rb') ).each do |lib_file|
  require lib_file
end


ENV['RACK_ENV'] ||= 'development'
