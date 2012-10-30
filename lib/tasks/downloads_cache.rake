namespace :downloads do
  namespace :cache do
    desc "Remove all cached downloads in /public/downloads/"
    task :clear => :environment do
      files = "#{Rails.root}/public/downloads/*"
      Dir[files].each do |file|
        File.delete file
      end
    end

    desc "Keeps 500 most recently used downloads"
    task :rotate => :environment do
      # Sort download files by modified time descending
      sorted_files = Dir["#{Rails.root}/public/downloads/*"].sort_by { |f| !test("M", f) }

      files_to_delete = sorted_files[501,-1]

      unless files_to_delete.nil?
        files_to_delete.each do |file|
          File.delete file
        end
      end
    end
  end
end
