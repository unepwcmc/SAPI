class PsqlCommand

  def initialize(sql_cmd)
    db_conf = ActiveRecord::Base.connection_config
    @host = db_conf[:host] || 'localhost'
    @port = db_conf[:port] || 5432
    @username = db_conf[:username]
    @password = db_conf[:password]
    @database = db_conf[:database]
    @sql_cmd = sql_cmd
    @psql_cmd = "psql -h #{@host} -p #{@port} -U #{@username} #{@database}"
  end

  def execute
    system("export PGPASSWORD=#{@password} && echo \"#{@sql_cmd.split("\n").join(' ')}\" | #{@psql_cmd}")
  end

end
