module Sapi
  def self.rebuild
    ActiveRecord::Base.connection.execute('SELECT * FROM sapi_rebuild()')
  end
  def self.fix_listing_changes
    ActiveRecord::Base.connection.execute('SELECT * FROM fix_cites_listing_changes()')
  end
end