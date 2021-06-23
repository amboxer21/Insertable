require 'rubygems'
require 'bundler/setup'
require 'active_record'
require 'active_support'

Dir["./lib/modules/*.rb"].each {|ruby_file_name|
  base_file_name = File.basename(ruby_file_name, '.rb')
  class_symbol   = ActiveSupport::Inflector.camelize(base_file_name).to_sym
  require(ruby_file_name)
}

Dir['./helpers/*.rb'].each {|ruby_file_name|
  base_file_name = File.basename(ruby_file_name, '.rb')
  class_symbol   = ActiveSupport::Inflector.camelize(base_file_name).to_sym
  require(ruby_file_name)
}

Dir['./lib/*.rb'].each {|ruby_file_name|
  base_file_name = File.basename(ruby_file_name, '.rb')
  class_symbol   = ActiveSupport::Inflector.camelize(base_file_name).to_sym
  require(ruby_file_name)
}

Dir['./mailers/*.rb'].each {|ruby_file_name|
  base_file_name = File.basename(ruby_file_name, '.rb')
  class_symbol   = ActiveSupport::Inflector.camelize(base_file_name).to_sym
  require(ruby_file_name)
}

Dir['./monkey_patches/*.rb'].each {|ruby_file_name|
  base_file_name = File.basename(ruby_file_name, '.rb')
  class_symbol   = ActiveSupport::Inflector.camelize(base_file_name).to_sym
  require(ruby_file_name)
}
