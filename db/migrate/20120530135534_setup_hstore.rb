class SetupHstore < ActiveRecord::Migration
  def self.up
    if Rails.env.staging? or Rails.env.production?
      puts "Please add extension by hand: CREATE EXTENSION hstore"
    else
      execute "CREATE EXTENSION IF NOT EXISTS hstore"
    end
  end

  def self.down
    if Rails.env.staging? or Rails.env.production?
      puts "Please drop extension by hand: DROP EXTENSION hstore"
    else
      execute "DROP EXTENSION hstore"
    end
  end
end
