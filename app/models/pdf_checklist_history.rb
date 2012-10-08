#Encoding: utf-8
require "prawn/measurement_extensions"
require Rails.root.join("lib/modules/pdf.rb")
class PdfChecklistHistory < ChecklistHistory
  include PDF

  def generate
    static_history_pdf = [Rails.root, "/public/static_history.pdf"].join
    attachment_pdf = [Rails.root, "/public/Historical_summary_of_CITES_annotations.pdf"].join
    tmp_history_pdf = [Rails.root, "/tmp/", SecureRandom.hex(8), '.pdf'].join

    static_page_count = get_page_count(static_history_pdf)
    #TODO refactor
    animalia, plantae = [], []
    page = 0
    begin
      res = super(page, 1000)
      animalia += res[0][:animalia]
      plantae += res[0][:plantae]
      page += 1
    end while res[0][:result_cnt] > 0

    Prawn::Document.new(:page_size => 'A4', :margin => 2.send(:cm)) do |pdf|
      pdf.default_leading 0
      pdf.font_size 9
      pdf.go_to_page(pdf.page_count)

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
      unless tc.kind_of? Checklist::HigherTaxaItem
        #filter out null records for higher taxa
        listings_subtable = pdf.make_table(tc.m_listing_changes.map do |lh|
          [
            "#{lh.species_listing_name}#{
              if lh.change_type_name == ChangeType::RESERVATION
                '/r'
              elsif lh.change_type_name == ChangeType::RESERVATION_WITHDRAWAL
                '/w'
              elsif lh.change_type_name == ChangeType::DELETION
                'Del'
              else
                nil
              end
            }",
            "#{lh.party_name}".upcase,
            "#{lh.effective_at ? lh.effective_at.strftime("%d/%m/%y") : nil}",
            "#{[lh.english_full_note, lh.spanish_full_note, lh.french_full_note].compact.join("\n")}".gsub(/NULL/,'')
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
