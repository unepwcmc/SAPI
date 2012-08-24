#Encoding: utf-8
require "prawn/measurement_extensions"
require Rails.root.join("lib/modules/pdf.rb")
class PdfChecklistHistory < ChecklistHistory
  include PDF

  #add higher taxa headers TODO refactor
  def post_process(taxon_concepts)
    #aggregate history
    prev_id = nil
    current_listing_history = nil
    res1 = []
    taxon_concepts.map do |tc|
      listing_change = {
        :effective_at => tc.effective_at,
        :change_type => tc.change_type,
        :species_listing => tc.species_listing,
        :party => tc.party,
        :listing_notes => tc.listing_notes
      }
      if tc.id != prev_id
        tc.listing_history = []
        current_listing_history = tc.listing_history
        res1 << tc
        prev_id = tc.id
      end
      current_listing_history << listing_change
    end
    #add higher taxa headers
    res2 = []
    ranks = ['PHYLUM', 'CLASS', 'ORDER', 'FAMILY', 'GENUS', 'SPECIES']
    header_ranks = 4 #use only this many from the ranks table for headers
    res1.each_with_index do |tc, i|
      # puts tc.full_name
      prev_path = if i==0
        ''
      else
        res1[i-1].taxonomic_position
      end
      curr_path = tc.taxonomic_position
      prev_path_segments = prev_path.split('.')
      curr_path_segments = curr_path.split('.')
      common_segments = 0
      for j in 0..prev_path_segments.length-1
        if curr_path_segments[j] == prev_path_segments[j]
          common_segments += 1
        else
          break
        end
      end
      # puts prev_path
      # puts curr_path
      # puts "common segments: #{common_segments}"
      missing_segments = unless prev_path.blank?
        if prev_path_segments.length < curr_path_segments.length
          prev_path_segments.length - common_segments
        else
          curr_path_segments.length - common_segments
        end
      else
        curr_path_segments.length - 1
      end
      # puts "missing segments: #{missing_segments}"
      if missing_segments > 1
        rank_idx = ranks.index(tc.rank_name)
        rank_idx = (ranks.length - 1) if rank_idx.nil?
        for k in (ranks.length - missing_segments)..(rank_idx > header_ranks - 1 ? header_ranks - 1 : rank_idx)
          # puts ranks[k]
          # puts tc.send("#{ranks[k].downcase}_name")
          res2 << TaxonConcept.new({
            :data => {
              'rank_name' => ranks[k],
              'full_name' => tc.send("#{ranks[k].downcase}_name")
            }
          })
        end
      end
      res2 << tc
    end
    res2
  end

  def generate
    static_history_pdf = [Rails.root, "/public/static_history.pdf"].join
    attachment_pdf = [Rails.root, "/public/Historical_summary_of_CITES_annotations.pdf"].join
    tmp_history_pdf    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.pdf'].join

    static_page_count = get_page_count(static_history_pdf)
    animalia = post_process(
      @taxon_concepts_rel.where("data->'kingdom_name' = 'Animalia'")
    )
    plantae = post_process(
      @taxon_concepts_rel.where("data->'kingdom_name' = 'Plantae'")
    )

    Prawn::Document.new(:page_size => 'A4', :margin => 2.send(:cm)) do |pdf|
      pdf.default_leading 0
      pdf.font_size 9
      pdf.go_to_page(pdf.page_count)

      draw_kingdom(pdf, animalia, 'FAUNA')
      draw_kingdom(pdf, plantae, 'FLORA')

      # Add summary line
      summary = summarise_filters
      pdf.repeat :all do
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.top + 20], :width  => pdf.bounds.width do
            pdf.text summary, :align => :center, :size => 8
            pdf.stroke_horizontal_rule
        end
      end

      #add page numbers
      string = "History of CITES listings – <page>"
      options = {
        :at => [pdf.bounds.right / 2 - 75, -30],
        :width => 150,
        :align => :center,
        :start_count_at => static_page_count - 2, # Ignore the first two cover pages
      }
      pdf.number_pages string, options

      pdf.render_file tmp_history_pdf
    end

    tmp_merged_pdf = merge_pdfs(static_history_pdf, tmp_history_pdf)
    download_path = attach_pdfs(tmp_merged_pdf, attachment_pdf)

    FileUtils.rm tmp_history_pdf
    FileUtils.rm tmp_merged_pdf

    return download_path
  end

  def draw_kingdom(pdf, kingdom, kingdom_name)
    pdf.text(kingdom_name, :size => 12, :align => :center)
    listings_table = []
    kingdom.each do |tc|
      unless listings_table.blank?
        pdf.table(listings_table,
          :column_widths => {0 => 142},
          :cell_style => {:borders => [], :padding => [1,0,1,0]}
        )
        listings_table = []
      end

      if tc.rank_name == 'PHYLUM'
        pdf.text "<b>#{tc.full_name.upcase}</b>",
          :size => 16,
          :align => :center,
          :inline_format => true
      elsif tc.rank_name == 'CLASS'
        pdf.pad(20){
          pdf.text "<b><u>#{tc.full_name.upcase}</u></b>",
          :size => 12,
          :inline_format => true
        }
      elsif ['ORDER','FAMILY'].include? tc.rank_name
        pdf.pad(10){
            pdf.formatted_text [
            {
              :text => tc.full_name.upcase,
              :styles => [:bold],
              :size => 10
            },
            {
              :text =>
              (tc.english_names_list.blank? ? '' : "(E) #{tc.english_names_list} ") },
            {
              :text =>
              (tc.spanish_names_list.blank? ? '' : "(S) #{tc.spanish_names_list} ") },
            {
              :text =>
              (tc.french_names_list.blank? ? '' : "(F) #{tc.french_names_list} ") }
          ]
        }
      end
      unless tc.new_record?
        #filter out null records for higher taxa
        unless tc.change_type.blank?
          listings_subtable = pdf.make_table(tc.listing_history.map do |lh|
            [
              "#{lh[:species_listing]}#{
                if lh[:change_type] == ChangeType::RESERVATION
                  '/r'
                elsif lh[:change_type] == ChangeType::RESERVATION_WITHDRAWAL
                  '/w'
                elsif lh[:change_type] == ChangeType::DELETION
                  'Del'
                else
                  nil
                end
              }",
              "#{lh[:party]}".upcase,
              "#{lh[:effective_at] ? Date.parse(lh[:effective_at]).strftime("%d/%m/%y") : nil}",
              "#{lh[:listing_notes]}".sub(/NULL/,'')#TODO
            ]
          end,
            {
              :column_widths => [27, 24, 45, 243],
              :cell_style => {:borders => [], :padding => [1,0,1,0]}
            }
          )
  
          listings_table << [
            pdf.make_cell(:content => "<i>#{tc.full_name}</i>", :inline_format => true),
            listings_subtable
          ]
        end
      end
    end
  end
end
