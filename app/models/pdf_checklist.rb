#Encoding: utf-8
require "prawn/measurement_extensions"
require Rails.root.join("lib/modules/pdf.rb")
class PdfChecklist < Checklist
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

      draw_kingdom(pdf, 'Animalia', 'FAUNA')
      draw_kingdom(pdf, 'Plantae', 'FLORA')

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

  def draw_kingdom(pdf, kingdom_name, kingdom_display_name)
    limit = 5000
    offset = 0
    pdf.text(kingdom_display_name, :size => 12, :align => :center)

    @indent = 15
    pdf.column_box([0, pdf.cursor], :columns => 2, :width => pdf.bounds.width) do

      begin

      #fetch data
      kingdom = MTaxonConcept.find_by_sql(
        Checklist::PdfIndexQuery.new(
          @taxon_concepts_rel.where("kingdom_name = '#{kingdom_name}'"),
          @common_names,
          @synonyms,
          limit,
          offset
        ).to_sql
      )
      offset += limit
      kingdom.each do |tc|
        entry = 
        if tc.read_attribute(:name_type) == 'synonym'
          #it's a synonym or common name entry
          "<i>#{tc.sort_name} = #{tc.full_name}</i>"
        elsif tc.read_attribute(:name_type) == 'common'
          "#{tc.sort_name} (#{tc.lng.upcase}): <i>#{tc.full_name}</i>"
        else
          res = if ['FAMILY','ORDER','CLASS'].include? tc.rank_name
            tc.full_name.upcase
          else
            tc.full_name
          end
          res = "<i>#{res}</i>" if ['SPECIES', 'SUBSPECIES', 'GENUS'].include? tc.rank_name
          res = "#{res} #{tc.spp}"
          res = "<b>#{res}</b>" if tc.cites_accepted
          res += " #{tc.generic_annotation_symbol}" unless tc.generic_annotation_symbol.blank?
          res += " <b>#{tc.current_listing}</b> "
          res += "<sup>#{tc.specific_annotation_symbol}</sup>" unless tc.specific_annotation_symbol.blank?
          res += " #{"#{tc.family_name}".upcase}"
          res += " (#{tc.class_name})" unless tc.class_name.blank?
          res += " (E) #{tc.english_names_list} " unless tc.english_names_list.blank?
          res += " (S) #{tc.spanish_names_list} " unless tc.spanish_names_list.blank?
          res += " (E) #{tc.french_names_list} " unless tc.french_names_list.blank?
          res
        end
        pdf.text entry,
          #:indent_paragraphs => @indent,
          :inline_format => true
      end
      end while not kingdom.empty?
    end
  end

end
