namespace :db do
  desc 'Converts existing user.is_managable? column to new user.role column'
  task :convert_to_role => :environment do
    User.all.each do |user|
      if user.is_manager?
        user.update_attributes(role: 'admin')
      else
        user.update_attributes(role: 'default')
      end
    end

    puts "All users have been converted to use the role column instead of is_manager"
  end
end