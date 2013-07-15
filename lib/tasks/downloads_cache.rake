namespace :downloads do
  DOWNLOAD_DIRS = ['checklist', 'eu_listings', 'cites_listings', 'cms_listings', 'quotas', 'cites_suspesions']
  namespace :cache do
    desc "Remove all cached downloads in /public/downloads/"
    task :clear => :environment do
      DOWNLOAD_DIRS.each do |dir|
        FileUtils.rm_rf(Dir["#{Rails.root}/public/downloads/#{dir}/*"], :secure => true)
      end
    end

    desc "Keeps 500 most recently used downloads"
    task :rotate => :environment do
      DOWNLOAD_DIRS.each do |dir|
        # Sort download files by modified time descending
        sorted_files = Dir["#{Rails.root}/public/downloads/#{dir}/*"].sort_by { |f| !test("M", f) }

        files_to_delete = sorted_files[501,-1]

        unless files_to_delete.nil?
          files_to_delete.each do |file|
            File.delete file
          end
        end
      end
    end

    desc "Update the cache for the featured downloads"
    task :update => :environment do
      modules = [
        Checklist::Pdf,
        Checklist::Json,
        Checklist::Csv
      ]

      # Default l
      params = {
        show_synonyms: "1",
        show_author: "1",
        show_english: "1",
        show_spanish: "1",
        show_french: "1",
        locale: "en",
        format: "json"
      }

      modules.each do |m|
        puts m::Index.new(params).generate
        puts m::History.new(params).generate
      end
    end
  end
end
