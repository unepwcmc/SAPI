#Encoding: utf-8
require "prawn/measurement_extensions"

class PdfChecklist < Checklist

  def generate
    Prawn::Document.new(:page_size => 'A4', :margin => 2.send(:cm), :template => Rails.root.join("public/static_index.pdf")) do |pdf|
      pdf.font_size 9
      pdf.go_to_page(pdf.page_count)
      draw_kingdom(pdf, animalia, 'FAUNA')
      draw_kingdom(pdf, plantae, 'FLORA')
      #add page numbers
      string = "CITES species index – <page>"
      options = {
        :at => [pdf.bounds.right / 2 - 75, 0],
        :width => 150,
        :align => :center,
        :page_filter => lambda{ |p| p > 2 },
        :start_count_at => 1,
      }
      pdf.number_pages string, options

    end
  end

  def draw_kingdom(pdf, kingdom, kingdom_name)
    pdf.start_new_page
    pdf.text(kingdom_name, :size => 12, :align => :center)
    pdf.column_box([0, pdf.cursor], :columns => 2, :width => pdf.bounds.width) do
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
                if ['SPECIES', 'SUBSPECIES'].include? tc.rank_name
                  [:italic]
                elsif tc.rank_name == 'GENUS'
                  [:italic, :bold]
                else
                  [:bold]
                end
            },
            {:text => "#{tc.spp} ", :styles => [:bold]},
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
            }
          ]
        end
      end
    end
  end

end