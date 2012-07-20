#Encoding: utf-8
require "prawn/measurement_extensions"
class PdfChecklistHistory < ChecklistHistory

  def generate
    Prawn::Document.generate("checklist_history.pdf", :page_size => 'A4', :margin => 2.send(:cm)) do |pdf|
      pdf.font_size 8
      pdf.default_leading 0

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
        :page_filter => lambda{ |p| p > 0 },
        :start_count_at => 1,
      }
      pdf.number_pages string, options

    end
  end

end