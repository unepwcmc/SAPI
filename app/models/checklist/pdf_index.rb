#Encoding: utf-8
require "prawn/measurement_extensions"
require Rails.root.join("lib/modules/pdf.rb")
class Checklist::PdfIndex < Checklist
  include PDF

  def initialize(options={})
    super(options.merge({:output_layout => :alphabetical}))
  end

  def generate
    static_index_pdf = [Rails.root, "/public/static_index.pdf"].join
    attachment_pdf = [Rails.root, "/public/CITES_abbreviations_and_annotations.pdf"].join
    tmp_index_pdf    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.pdf'].join

    static_page_count = get_page_count(static_index_pdf)

    Prawn::Document.new(:page_size => 'A4', :margin => 2.send(:cm)) do |pdf|
      pdf.font_size 9

      animalia_query = Checklist::PdfIndexQuery.new(
        @taxon_concepts_rel.where("kingdom_name = 'Animalia'"),
        @common_names,
        @synonyms
      )
      Checklist::PdfIndexKingdom.new(pdf, animalia_query, 'FAUNA').to_pdf

      plantae_query = Checklist::PdfIndexQuery.new(
        @taxon_concepts_rel.where("kingdom_name = 'Plantae'"),
        @common_names,
        @synonyms
      )
      Checklist::PdfIndexKingdom.new(pdf, plantae_query, 'FLORA').to_pdf

      # Add summary line
      summary = summarise_filters
      pdf.repeat :all do
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.top + 20], :width  => pdf.bounds.width do
            pdf.text summary, :align => :center, :size => 8
            pdf.stroke_horizontal_rule
        end
      end

      #add page numbers
      string = "CITES Species Index – <page>"
      options = {
        :at => [pdf.bounds.right / 2 - 75, -30],
        :width => 150,
        :align => :center,
        :start_count_at => static_page_count - 2, # Ignore the first two cover pages
      }
      pdf.number_pages string, options

      pdf.render_file tmp_index_pdf
    end

    tmp_merged_pdf = merge_pdfs(static_index_pdf, tmp_index_pdf)
    download_path = attach_pdfs(tmp_merged_pdf, attachment_pdf)

    FileUtils.rm tmp_index_pdf
    FileUtils.rm tmp_merged_pdf

    return download_path
  end

end
