class SetupUnaccent < ActiveRecord::Migration
  def self.up
    if Rails.env.staging? or Rails.env.production?
      puts "Please add extension by hand: CREATE EXTENSION unaccent"
    else
      execute "CREATE EXTENSION IF NOT EXISTS unaccent"
    end
  end

  def self.down
    if Rails.env.staging? or Rails.env.production?
      puts "Please drop extension by hand: DROP EXTENSION unaccent"
    else
      execute "DROP EXTENSION unaccent"
    end
  end
end
