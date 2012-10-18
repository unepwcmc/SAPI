#Encoding: utf-8
class Checklist::Pdf::History < Checklist::History
  include Checklist::Pdf::Document
  include Checklist::Pdf::HistoryContent

  def initialize(options={})
    super(options)
    @static_pdf = [Rails.root, "/public/static_history.pdf"].join
    @attachment_pdf = [Rails.root, "/public/Historical_summary_of_CITES_annotations.pdf"].join
    @tmp_pdf = [Rails.root, "/tmp/", SecureRandom.hex(8), '.pdf'].join
    @footnote_title_string = "History of CITES listings – <page>"
  end

  def prepare_queries
    @taxon_concepts_rel = @taxon_concepts_rel.where("cites_listed = 't'").
      includes(:m_listing_changes).
      where("NOT (listing_changes_mview.change_type_name = 'DELETION' " +
        "AND listing_changes_mview.species_listing_name IS NOT NULL " +
        "AND listing_changes_mview.party_name IS NULL)"
      )
    @animalia_rel = @taxon_concepts_rel.where("kingdom_name = 'Animalia'")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_name = 'Plantae'")
  end

end
