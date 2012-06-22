module Sapi
  def self.rebuild
    ActiveRecord::Base.connection.execute('SELECT * FROM sapi_rebuild()')
  end
end