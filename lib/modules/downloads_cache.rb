module DownloadsCache

  LISTINGS_DOWNLOAD_DIRS = ['checklist', 'eu_listings', 'cites_listings', 'cms_listings']
  ADMIN_DOWNLOAD_DIRS = [
    'taxon_concepts_names', 'synonyms_and_trade_names',
    'orphaned_taxon_concepts', 'taxon_concepts_distributions', 'common_names',
    'species_reference_output', 'standard_reference_output',
    'documents'
  ]
  DOWNLOAD_DIRS = LISTINGS_DOWNLOAD_DIRS + [
    'quotas', 'cites_suspensions', 'eu_decisions', 'shipments', 'comptab',
    'gross_exports', 'gross_imports', 'net_exports', 'net_imports',
    'trade_download_stats'
  ] + ADMIN_DOWNLOAD_DIRS

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
      Rails.logger.debug("Clearing #{dir}")
      FileUtils.rm_rf(Dir["#{downloads_path(dir)}/*"], :secure => true)
    end
  end

  # for admin purposes
  def self.clear
    clear_dirs(DOWNLOAD_DIRS)
    Download.delete_all
  end

  def self.clear_cites_listings
    clear_dirs(['cites_listings'])
  end

  def self.clear_eu_listings
    clear_dirs(['eu_listings'])
  end

  def self.clear_cms_listings
    clear_dirs(['cms_listings'])
  end

  ## Clear admin downloads
  def self.clear_taxon_concepts
    clear_dirs(['taxon_concepts_names', 'synonyms_and_trade_names', 'orphaned_taxon_concepts'])
  end

  def self.clear_taxon_relationships
    clear_dirs(['taxon_concepts_names', 'synonyms_and_trade_names'])
  end

  def self.clear_distributions
    clear_dirs(['taxon_concepts_distributions'])
  end

  def self.clear_taxon_commons
    clear_dirs(['common_names'])
  end

  def self.clear_listing_changes
    false # no op, listing changes will need mview refresh anyway
  end

  def self.clear_taxon_instruments
    false # no op, instruments will need mview refresh anyway
  end

  def self.clear_taxon_concept_references
    clear_dirs(['species_reference_output', 'standard_reference_output'])
  end

  def self.clear_documents
    clear_dirs(['documents'])
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

  class << self
    alias :clear_eu_opinions :clear_eu_decisions
    alias :clear_eu_suspensions :clear_eu_decisions
  end

  # cleared after save & destroy
  def self.clear_shipments
    clear_dirs(['shipments'])
    clear_dirs(['comptab'])
    clear_dirs(['gross_exports'])
    clear_dirs(['gross_imports'])
    clear_dirs(['net_exports'])
    clear_dirs(['net_imports'])
  end

  def self.clear_trade_download_stats
    clear_dirs(['trade_download_stats'])
  end

  def self.update
    clear
    update_species_downloads
    update_checklist_downloads
    update_admin_downloads
  end

  def self.update_checklist_downloads
    puts "Updating CITES Checklist downloads"
    modules = [
      Checklist::Pdf,
      Checklist::Csv,
      Checklist::Json
    ]
    ['en', 'es', 'fr'].each do |locale|
      # full download parameters
      params = {
        show_synonyms: "1",
        show_author: "1",
        show_english: "1",
        show_spanish: "1",
        show_french: "1",
        intro: "1",
        locale: locale
      }

      modules.each do |m|
        elapsed_time = Benchmark.realtime do
          puts m::Index.new(params).generate
        end
        puts "#{Time.now} #{m}::Index download #{locale} generated in #{elapsed_time}s"
        elapsed_time = Benchmark.realtime do
          puts m::History.new(params).generate
        end
        puts "#{Time.now} #{m}::History download #{locale} generated in #{elapsed_time}s"
      end
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
      Species::EuDecisionsExport.new(set: 'current', decision_types: {}).export
    end
    puts "#{Time.now} current EU Decisions download generated in #{elapsed_time}s"
    elapsed_time = Benchmark.realtime do
      Species::EuDecisionsExport.new(set: 'all', decision_types: {}).export
    end
    puts "#{Time.now} all EU Decisions download generated in #{elapsed_time}s"
  end

  def self.update_admin_downloads
    puts "Updating admin downloads"
    [Taxonomy::CITES_EU, Taxonomy::CMS].each do |taxonomy_name|
      puts "#{taxonomy_name} Names"
      elapsed_time = Benchmark.realtime do
        Species::TaxonConceptsNamesExport.new(:taxonomy => taxonomy_name).export
      end
      puts "#{Time.now} Taxon Concepts Names #{taxonomy_name} download generated in #{elapsed_time}s"
      puts "#{taxonomy_name} Synonyms and Trade Names"
      elapsed_time = Benchmark.realtime do
        Species::SynonymsAndTradeNamesExport.new(:taxonomy => taxonomy_name).export
      end
      puts "#{Time.now} Synonyms & Trade Names #{taxonomy_name} download generated in #{elapsed_time}s"
      puts "#{taxonomy_name} Distributions"
      elapsed_time = Benchmark.realtime do
        Species::TaxonConceptsDistributionsExport.new(:taxonomy => taxonomy_name).export
      end
      puts "#{Time.now} Distributions #{taxonomy_name} download generated in #{elapsed_time}s"
      puts "#{Time.now} Common Names #{taxonomy_name} download generated in #{elapsed_time}s"
      puts "#{taxonomy_name} Common Names"
      elapsed_time = Benchmark.realtime do
        Species::CommonNamesExport.new(:taxonomy => taxonomy_name).export
      end
      puts "#{Time.now} Common Names #{taxonomy_name} download generated in #{elapsed_time}s"
    end
  end
end
