#Encoding: utf-8
require "prawn/measurement_extensions"
require Rails.root.join("lib/modules/pdf.rb")
class PdfChecklist < Checklist
  include PDF

  def initialize(options={})
    super(options.merge({:output_layout => :alphabetical}))
  end

  #sort taxon concepts, their synonyms and common names
  def post_process(taxon_concepts)
    merge_runs = [taxon_concepts]
    if(@synonyms)
      synonyms_run = taxon_concepts.map do |tc|
        tc.synonyms.map do |s|
          Checklist::SynonymItem.new(:synonym_name => s, :full_name => tc.full_name)
        end
      end.flatten
      merge_runs << synonyms_run
    end
    if(@common_names)
      common_names_run = taxon_concepts.map do |tc|
        ['english', 'spanish', 'french'].map do |lng|
          tc.send("#{lng}_names").map do |c|
            Checklist::CommonNameItem.new(
              :common_name => c, :full_name => tc.full_name, :lng => lng
            )
          end
        end
      end.flatten.compact
      merge_runs << common_names_run
    end
    merge_runs.flatten.sort do |a,b|
      (a.full_name || '') <=> (b.full_name || '')
    end
  end

  def generate
    static_index_pdf = [Rails.root, "/public/static_index.pdf"].join
    attachment_pdf = [Rails.root, "/public/CITES_abbreviations_and_annotations.pdf"].join
    tmp_index_pdf    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.pdf'].join

    static_page_count = get_page_count(static_index_pdf)

    animalia, plantae = [], []
    page = 0
    begin
      res = super(page, 1000)
      animalia += res[0][:animalia]
      plantae += res[0][:plantae]
      page += 1
    end while res[0][:result_cnt] > 0

    animalia = post_process(animalia)
    plantae = post_process(plantae)

    Prawn::Document.new(:page_size => 'A4', :margin => 2.send(:cm)) do |pdf|
      pdf.font_size 9

      draw_kingdom(pdf, animalia, 'FAUNA') unless animalia.empty?
      draw_kingdom(pdf, plantae, 'FLORA') unless plantae.empty?

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

  def draw_kingdom(pdf, kingdom, kingdom_name)
    pdf.text(kingdom_name, :size => 12, :align => :center)
    @indent = 15
    pdf.column_box([0, pdf.cursor], :columns => 2, :width => pdf.bounds.width) do
      kingdom.each do |tc|
        entry = 
        if tc.kind_of? Checklist::SynonymItem
          #it's a synonym or common name entry
          "<i>#{tc.synonym_name} = #{tc.full_name}</i>"
        elsif tc.kind_of? Checklist::CommonNameItem
          "#{tc.common_name} (#{tc.lng[0].upcase}): <i>#{tc.full_name}</i>"
        else
          res = if ['FAMILY','ORDER','CLASS'].include? tc.rank_name
            tc.full_name.upcase
          else
            tc.full_name
          end
          res = "<i>#{res}</i>" if ['SPECIES', 'SUBSPECIES', 'GENUS'].include? tc.rank_name
          res = "#{res} #{tc.spp}"
          res = "<b>#{res}</b>" if tc.cites_accepted
          res += " <b>#{tc.current_listing}</b> #{"#{tc.family_name}".upcase} (#{tc.class_name})"
          res += " (E) #{tc.english_names_list} " unless tc.english_names_list.blank?
          res += " (S) #{tc.spanish_names_list} " unless tc.spanish_names_list.blank?
          res += " (E) #{tc.french_names_list} " unless tc.french_names_list.blank?
          res
        end
        pdf.text entry,
          #:indent_paragraphs => @indent,
          :inline_format => true
      end
    end
  end

end
