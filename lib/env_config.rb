require 'yaml'
require 'singleton'

class EnvConfig
  include Singleton

  def initialize
    @data = YAML::load(IO.read('./config/database.yml'))
  end

  def current_env
    @current_env ||= ENV['INSERTABLE_ENV'].downcase
  end

  def logfiles
    @data[current_env]['logfiles'] || Array.new
  end

  def logfile
    @data[current_env]['logfile'] || Array.new
  end
  
  def db_host
    @data[current_env]['database']['host']
  end
  
  def db_password
    @data[current_env]['database']['password']
  end
  
  def db_username
    @data[current_env]['database']['username']
  end

  def db_adapter
    @data[current_env]['database']['adapter']
  end

  def db_database
    @data[current_env]['database']['database']
  end

end
