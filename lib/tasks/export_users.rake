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

  desc 'Export all api users active within 13 months'
  task :recent_active_api_users => :environment do
    FILENAME = "tmp/recent_active_api_users_#{Date.today.to_s}.csv".freeze
    COLUMN_NAMES = %w(id name email role organisation).freeze

    CSV.open(FILENAME, 'w') do |csv|
      csv << [COLUMN_NAMES, 'country', 'last_active'].flatten
      User.order(:name).each do |user|
        puts "processing User #{user.email} #{user.name}"
        api_requests = user.api_requests.where('created_at > ?', 13.months.ago).select(:created_at)
        if api_requests.count == 0
          puts "User #{user.email} not active, skipping..."
          next
        end
        country = user.geo_entity && user.geo_entity.name_en
        last_active = api_requests.order(:created_at).last.created_at
        csv << user.attributes.slice(*COLUMN_NAMES).merge(country: country, last_active: last_active).values
      end
    end
  end
end
