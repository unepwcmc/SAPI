#Encoding: utf-8
require "prawn/measurement_extensions"
require Rails.root.join("lib/modules/pdf.rb")
class PdfChecklist < Checklist
  include PDF

  #merge sort on taxon concepts, their synonyms and common names #TODO
  def post_process(taxon_concepts)
    if(@synonyms)
      #synonyms = taxon_concepts.map(:synonyms).sort
    end
    if(@common_names)
      #common_names = taxon_concepts.map(:english, :spanish, :french).sort
    end
    #merge sort
  end

  def generate
    static_index_pdf = [Rails.root, "/public/static_index.pdf"].join
    tmp_index_pdf    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.pdf'].join

    static_page_count = get_page_count(static_index_pdf)
    animalia = @taxon_concepts_rel.where("data->'kingdom_name' = 'Animalia'")
    plantae = @taxon_concepts_rel.where("data->'kingdom_name' = 'Plantae'")

    Prawn::Document.new(:page_size => 'A4', :margin => 2.send(:cm)) do |pdf|
      pdf.font_size 9
      draw_kingdom(pdf, animalia, 'FAUNA')
      draw_kingdom(pdf, plantae, 'FLORA')

      # Add summary line
      summary = Checklist.summarise_filters(@params)
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

    download_path = merge_pdfs(static_index_pdf, tmp_index_pdf)

    FileUtils.rm tmp_index_pdf

    return download_path
  end

  def draw_kingdom(pdf, kingdom, kingdom_name)
    pdf.text(kingdom_name, :size => 12, :align => :center)
    pdf.column_box([0, pdf.cursor], :columns => 2, :width => pdf.bounds.width, :total_right_padding => 20) do
      kingdom.each do |tc|
        unless tc.full_name.blank?
          pdf.formatted_text [
            {
              :text =>
                if ['FAMILY','ORDER','CLASS'].include? tc.rank_name
                  tc.full_name.upcase
                else
                  tc.full_name
                end + ' ',
              :styles => 
                [] <<
                if ['SPECIES', 'SUBSPECIES', 'GENUS'].include? tc.rank_name
                  :italic
                end <<
                if tc.cites_accepted
                  :bold
                end
            },
            {
              :text => "#{tc.spp} ",
              :styles =>  (tc.cites_accepted ? [:bold] : [])
            },
            {:text => tc.current_listing + ' ', :styles => [:bold]},
            {:text => "#{tc.family_name} ".upcase},
            {:text => "(#{tc.class_name}) "},
            {
              :text =>
                unless tc.english.blank?
                  "(E) #{tc.english} "
                else
                  ''
                end
            },
            {
              :text =>
                unless tc.spanish.blank?
                  "(S) #{tc.spanish} "
                else
                  ''
                end
            },
            {
              :text =>
                unless tc.french.blank?
                  "(F) #{tc.french} "
                else
                  ''
                end
            },
            {
              :text =>
                unless tc.synonyms.blank?
                  "(SYN) #{tc.synonyms} "
                else
                  ''
                end
            }
          ]
        end
      end
    end
  end

end
