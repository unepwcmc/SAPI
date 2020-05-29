namespace :export do
  desc 'Export all users'
  task :users => :environment do
    FILENAME = "tmp/users_#{Date.today.to_s}.csv".freeze
    COLUMN_NAMES = %w(id name email role organisation is_cites_authority is_active).freeze

    CSV.open(FILENAME, 'w') do |csv|
      csv << [COLUMN_NAMES, 'country'].flatten
      User.order(:name).each do |user|
        country = user.geo_entity && user.geo_entity.name_en
        csv << user.attributes.slice(*COLUMN_NAMES).merge(country: country).values
      end
    end
  end
end
