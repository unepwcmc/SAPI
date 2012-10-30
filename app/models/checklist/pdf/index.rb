#Encoding: utf-8
class Checklist::Pdf::Index < Checklist::Index
  include Checklist::Pdf::Document
  include Checklist::Pdf::IndexContent

  def initialize(options={})
    @ext = 'pdf'
    super(options)
    @static_pdf     = [Rails.root, "/public/static_index.pdf"].join
    @attachment_pdf = [Rails.root, "/public/CITES_abbreviations_and_annotations.pdf"].join
    @tmp_pdf        = [Rails.root, "/tmp/", SecureRandom.hex(8), '.pdf'].join
    @tmp_merged_pdf = [Rails.root, "/tmp/", SecureRandom.hex(8), '.pdf'].join
    @footnote_title_string = "CITES Species Index – <page>"
  end

  def prepare_kingdom_queries
    super
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

end
