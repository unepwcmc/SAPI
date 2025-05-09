class SetupUnaccent < ActiveRecord::Migration[4.2]
  def self.up
    if Rails.env.staging? or Rails.env.production?
      Rails.logger.debug 'Please add extension by hand: CREATE EXTENSION unaccent'
    else
      execute 'CREATE EXTENSION IF NOT EXISTS unaccent'
    end
  end

  def self.down
    if Rails.env.staging? or Rails.env.production?
      Rails.logger.debug 'Please drop extension by hand: DROP EXTENSION unaccent'
    else
      execute 'DROP EXTENSION unaccent'
    end
  end
end
