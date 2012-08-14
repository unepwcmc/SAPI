#Encoding: utf-8
require "prawn/measurement_extensions"
require Rails.root.join("lib/modules/pdf.rb")
class PdfChecklistHistory < ChecklistHistory
  include PDF

  def generate
    static_history_pdf = [Rails.root, "/public/static_history.pdf"].join
    tmp_history_pdf    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.pdf'].join

    static_page_count = get_page_count(static_history_pdf)

    Prawn::Document.new(:page_size => 'A4', :margin => 2.send(:cm)) do |pdf|
      pdf.default_leading 0
      pdf.font_size 9
      pdf.go_to_page(pdf.page_count)

      listings_table = []
      @taxon_concepts.each do |tc|
        unless listings_table.blank?
          pdf.table(listings_table,
            :column_widths => {0 => 142},
            :cell_style => {:borders => [], :padding => [1,0,1,0]}
          )
          listings_table = []
        end
        if tc.rank_name == 'KINGDOM'
          pdf.text "<b>#{tc.full_name.upcase}</b>",
            :size => 20,
            :align => :center,
            :inline_format => true
        elsif tc.rank_name == 'PHYLUM'
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
              { :text => (tc.english.blank? ? '' : "(E) #{tc.english} ") },
              { :text => (tc.spanish.blank? ? '' : "(S) #{tc.spanish} ") },
              { :text => (tc.french.blank? ? '' : "(F) #{tc.french} ") }
            ]
          }
        end

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
      #add page numbers
      string = "History of CITES listings – <page>"
      options = {
        :at => [pdf.bounds.right / 2 - 75, 0],
        :width => 150,
        :align => :center,
        :start_count_at => static_page_count - 2, # Ignore the first two cover pages
      }
      pdf.number_pages string, options

      pdf.render_file tmp_history_pdf
    end

    download_path = merge_pdfs(static_history_pdf, tmp_history_pdf)

    FileUtils.rm tmp_history_pdf

    return download_path
  end

end
