class PsqlCommand

  def initialize(sql_cmd)
    db_conf = ActiveRecord::Base.connection_config
    @host = db_conf[:host] || 'localhost'
    @port = db_conf[:port] || 5432
    @username = db_conf[:username]
    @password = db_conf[:password]
    @database = db_conf[:database]
    # remove comments form multi line sql
    @sql_cmd = sql_cmd.gsub(/--.*$/, ' ')
    @psql_cmd = "psql -h #{@host} -p #{@port} -U #{@username} #{@database}"
  end

  def execute
    unless system("export PGPASSWORD=#{@password} && echo \"#{@sql_cmd.split("\n").join(' ')}\" | #{@psql_cmd}")
      Rails.logger.error("#{$!}")
    end
  end

end
