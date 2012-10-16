require "prawn/measurement_extensions"
require Rails.root.join("lib/modules/pdf.rb")
class Checklist::PdfChecklist < Checklist::Checklist
  include PDF

  def prepare_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_name = 'Animalia'")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_name = 'Plantae'")
  end

  def generate
    prepare_queries
    generate_pdf
    finalize
    @download_path
  end

  def generate_pdf
    Prawn::Document.new(:page_size => 'A4', :margin => 2.send(:cm)) do |pdf|
      pdf.default_leading 0
      pdf.font_size 9
      pdf.go_to_page(pdf.page_count)

      yield(pdf)

      # Add summary line
      summary = summarise_filters
      pdf.repeat :all do
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.top + 20], :width  => pdf.bounds.width do
            pdf.text summary, :align => :center, :size => 8
            pdf.stroke_horizontal_rule
        end
      end

      #add page numbers
      options = {
        :at => [pdf.bounds.right / 2 - 75, -30],
        :width => 150,
        :align => :center,
        :start_count_at => get_page_count(@static_pdf) - 2, # Ignore the first two cover pages
      }
      pdf.number_pages @footnote_title_string, options

      pdf.render_file @tmp_pdf
    end

    @tmp_merged_pdf = merge_pdfs(@static_pdf, @tmp_pdf)
    @download_path = attach_pdfs(@tmp_merged_pdf, @attachment_pdf)
  end

  def finalize
    FileUtils.rm @tmp_pdf
    FileUtils.rm @tmp_merged_pdf
  end

end