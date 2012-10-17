class Checklist::Csv::History < Checklist::Checklist
  include Checklist::Csv::Formatter

  def initialize(options={})
    super(options.merge({
      :output_layout => :taxonomic,
      :synonyms => false
    }))
    @tmp_csv    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.csv'].join
  end

  def prepare_queries
    @taxon_concepts_rel = @taxon_concepts_rel.where("cites_listed = 't'").
      joins(:m_listing_changes).select('taxon_concept_id').
      where("NOT (listing_changes_mview.change_type_name = 'DELETION' " +
        "AND listing_changes_mview.species_listing_name IS NOT NULL " +
        "AND listing_changes_mview.party_name IS NULL)"
      )
    @animalia_rel = @taxon_concepts_rel.where("kingdom_name = 'Animalia'")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_name = 'Plantae'")
  end

  def generate
    prepare_queries
    generate_csv do |csv|
      puts "animalia"
      fetcher = Checklist::HistoryFetcher.new(@animalia_rel)
      Checklist::Csv::HistoryKingdom.new(csv, fetcher, 'FAUNA').to_csv
      puts "plantae"
      fetcher = Checklist::HistoryFetcher.new(@plantae_rel)
      Checklist::Csv::HistoryKingdom.new(csv, fetcher, 'FLORA').to_csv
    end
    puts 'done'
    @download_path
  end

end
