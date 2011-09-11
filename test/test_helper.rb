# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

if ENV.has_key?('USE_SIMPLECOV')
  require 'simplecov'
  SimpleCov.start do
    add_group 'Libraries', 'lib'
  end
end

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
begin
  require 'shoulda'
rescue LoadError
  puts 'WARNING: missing shoulda library, cannot continue run tests'
  exit
end

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
