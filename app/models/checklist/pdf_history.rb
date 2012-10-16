#Encoding: utf-8
class Checklist::PdfHistory < Checklist::PdfChecklist

  def initialize(options={})
    super(options.merge({
      :output_layout => :taxonomic,
      :synonyms => false
    }))
    @taxon_concepts_rel = @taxon_concepts_rel.where("cites_listed = 't'").includes(:m_listing_changes)
    @static_pdf = [Rails.root, "/public/static_history.pdf"].join
    @attachment_pdf = [Rails.root, "/public/Historical_summary_of_CITES_annotations.pdf"].join
    @tmp_pdf = [Rails.root, "/tmp/", SecureRandom.hex(8), '.pdf'].join
    @footnote_title_string = "History of CITES listings – <page>"
  end

  def generate_pdf
    super do |pdf|
      Checklist::PdfHistoryKingdom.new(pdf, @animalia_rel, 'FAUNA').to_pdf
      Checklist::PdfHistoryKingdom.new(pdf, @plantae_rel, 'FLORA').to_pdf
    end

  end

end
