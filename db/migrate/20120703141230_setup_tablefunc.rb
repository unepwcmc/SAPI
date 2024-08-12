class SetupTablefunc < ActiveRecord::Migration[4.2]
  def self.up
    if Rails.env.staging? or Rails.env.production?
      Rails.logger.debug 'Please add extension by hand: CREATE EXTENSION tablefunc'
    else
      execute 'CREATE EXTENSION IF NOT EXISTS tablefunc'
    end
  end

  def self.down
    if Rails.env.staging? or Rails.env.production?
      Rails.logger.debug 'Please drop extension by hand: DROP EXTENSION tablefunc'
    else
      execute 'DROP EXTENSION tablefunc'
    end
  end
end
