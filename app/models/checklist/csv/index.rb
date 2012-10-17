#Encoding: utf-8
class Checklist::Csv::Index < Checklist::Checklist
  include Checklist::Csv::Formatter

  def initialize(options={})
    super(options.merge({:output_layout => :alphabetical}))
    @tmp_csv    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.csv'].join
  end

  def prepare_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_name = 'Animalia'")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_name = 'Plantae'")
  end

  def generate
    prepare_queries
    generate_csv do |csv|
      fetcher = Checklist::IndexFetcher.new(@animalia_rel)
      Checklist::Csv::IndexKingdom.new(csv, fetcher, 'FAUNA').to_csv
      fetcher = Checklist::IndexFetcher.new(@plantae_rel)
      Checklist::Csv::IndexKingdom.new(csv, fetcher, 'FLORA').to_csv
    end
    @download_path
  end

end
