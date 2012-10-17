#Encoding: utf-8
class Checklist::Pdf::Index < Checklist::Checklist
  include Checklist::Pdf::Formatter

  def initialize(options={})
    super(options.merge({:output_layout => :alphabetical}))
    @static_pdf = [Rails.root, "/public/static_index.pdf"].join
    @attachment_pdf = [Rails.root, "/public/CITES_abbreviations_and_annotations.pdf"].join
    @tmp_pdf    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.pdf'].join
    @footnote_title_string = "CITES Species Index – <page>"
  end

  def prepare_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_name = 'Animalia'")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_name = 'Plantae'")
    @animalia_query = Checklist::Pdf::IndexQuery.new(
      @animalia_rel,
      @common_names,
      @synonyms
    )
    @plantae_query = Checklist::Pdf::IndexQuery.new(
      @plantae_rel,
      @common_names,
      @synonyms
    )
  end

  def generate
    prepare_queries
    generate_pdf do |pdf|
      fetcher = Checklist::Pdf::IndexFetcher.new(@animalia_query)
      Checklist::Pdf::IndexKingdom.new(pdf, fetcher, 'FAUNA').to_pdf
      fetcher = Checklist::Pdf::IndexFetcher.new(@plantae_query)
      Checklist::Pdf::IndexKingdom.new(pdf, fetcher, 'FLORA').to_pdf
    end
    finalize
    @download_path
  end

end
