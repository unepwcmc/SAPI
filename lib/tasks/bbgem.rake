# Generated with 'brightbox' on 2012-05-08 09:53:55 +0100
unless Rake::Task.task_defined?("db:create") 
  namespace(:db) do
task :create do
  puts "This is a dummy task installed by the Brightbox command"
  puts "Your Rails version is too old to support the db:create task"
  puts "Either upgrade to Rails >=2.0 to use the inbuilt facilities"
  puts "Or create the database by hand if you haven't already"
end
  end
end
unless Rake::Task.task_defined?("db:check:config") 

  def rails_env
if defined?(Rails) and Rails.respond_to? :env
  Rails.env
elsif defined?(RAILS_ENV)
  RAILS_ENV
else
  "production"
end
  end

  def pe(message)
p "#{rails_env}: #{message}"
  end

  def brightbox_sanity_checks(config)
%w(username password database host).each do |entry|
  pe "#{entry} entry missing" unless config[entry]
end
db=config['database']
host=config['host']
if host && host !~ /^.*(sqlreadwrite|mysql.vm).brightbox.net$/
  pe "'#{host}' does not look like one of the Brightbox MySQL clusters"
elsif db && db !~ /\A#{config['username']}/
  pe "database name should start with '#{config['username']}' if using cluster"
end
  end
  
require 'yaml'

def read_database_yml
  db_yml = File.join(File.dirname(__FILE__), "..", "..", "config", "database.yml")
  if File.exist?(db_yml)
    return YAML.load(File.open(db_yml))
  else
    return {}
  end
end

namespace(:db) do
  namespace(:check) do
desc "Check database.yml config"
task :config do
  p "Checking database mysql configuration..."
  if config=read_database_yml[rails_env]
    case config['adapter']
    when nil
      pe "adapter entry missing."
    when 'mysql'
      brightbox_sanity_checks(config)
    else
      pe "using #{config['adapter']} - halting checks"
    end
  else
    pe "section missing."
  end
end
  end
end
  end