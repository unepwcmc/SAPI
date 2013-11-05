module DownloadsCache

  LISTINGS_DOWNLOAD_DIRS = ['checklist', 'eu_listings', 'cites_listings', 'cms_listings']
  DOWNLOAD_DIRS = LISTINGS_DOWNLOAD_DIRS + ['quotas', 'cites_suspensions', 'eu_decisions']

  def self.quotas_path
    downloads_path('quotas')
  end

  def self.cites_suspensions_path
    downloads_path('cites_suspensions')
  end

  def self.eu_decisions_path
    downloads_path('eu_decisions')
  end

  def self.downloads_path(dir)
    "#{Rails.root}/public/downloads/#{dir}"
  end

  def self.clear_dirs(dirs)
    dirs.each do |dir|
      FileUtils.rm_rf(Dir["#{downloads_path(dir)}/*"], :secure => true)
    end
  end

  # for admin purposes
  def self.clear
    clear_dirs(DOWNLOAD_DIRS)
  end

  # cleared after destroy
  def self.clear_quotas
    clear_dirs(['quotas'])
  end

  # cleared after destroy
  def self.clear_cites_suspensions
    clear_dirs(['cites_suspensions'])
  end

  # cleared after destroy
  def self.clear_eu_decisions
    clear_dirs(['eu_decisions'])
  end

  def self.update
    clear
    update_species_downloads
    update_checklist_downloads
  end

  def self.update_checklist_downloads
    puts "Updating CITES Checklist downloads"
    modules = [
      Checklist::Pdf,
      Checklist::Csv,
      Checklist::Json
    ]

    # full download parameters
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
      elapsed_time = Benchmark.realtime do
        puts m::Index.new(params).generate
      end
      puts "#{Time.now} #{m}::Index download generated in #{elapsed_time}s"
      elapsed_time = Benchmark.realtime do
        puts m::History.new(params).generate
      end
      puts "#{Time.now} #{m}::History download generated in #{elapsed_time}s"
    end
  end

  def self.update_species_downloads
    puts "Updating Species+ downloads"
    Designation.dict.each do |d|
      elapsed_time = Benchmark.realtime do
        Species::ListingsExportFactory.new(:designation => d).export
      end
      puts "#{Time.now} #{d} Listings download generated in #{elapsed_time}s"
    end

    elapsed_time = Benchmark.realtime do
      CitesSuspension.export('set' => 'current')
    end
    puts "#{Time.now} current CITES Suspensions download generated in #{elapsed_time}s"
    elapsed_time = Benchmark.realtime do
      CitesSuspension.export('set' => 'all')
    end
    puts "#{Time.now} all CITES Suspensions download generated in #{elapsed_time}s"

    elapsed_time = Benchmark.realtime do
      Quota.export('set' => 'current')
    end
    puts "#{Time.now} current CITES Quotas download generated in #{elapsed_time}s"
    elapsed_time = Benchmark.realtime do
      Quota.export('set' => 'all')
    end
    puts "#{Time.now} all CITES Quotas download generated in #{elapsed_time}s"

    elapsed_time = Benchmark.realtime do
      EuDecision.export('set' => 'current', 'decision_types' => {})
    end
    puts "#{Time.now} current EU Decisions download generated in #{elapsed_time}s"
    elapsed_time = Benchmark.realtime do
      EuDecision.export('set' => 'all', 'decision_types' => {})
    end
    puts "#{Time.now} all EU Decisions download generated in #{elapsed_time}s"
  end
end