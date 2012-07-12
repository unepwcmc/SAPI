#Encoding: utf-8
require "prawn/measurement_extensions"
class PdfChecklistHistory < ChecklistHistory

  def generate
    Prawn::Document.generate("checklist_history.pdf", :page_size => 'A4', :margin => 2.send(:cm)) do |pdf|
      pdf.font_size 9
      prev_id = nil
      listings_table = []
      @taxon_concepts_rel.each do |tc|
        unless tc.full_name.blank? || prev_id == tc.taxon_concept_id
          unless listings_table.blank?
            pdf.table(listings_table,
              :column_widths => [140, 28, 22, 46, 245],
              :cell_style => { :inline_format => true }
            )
            listings_table = []
          end
          prev_id = tc.taxon_concept_id
          omit_name = false
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
            pdf.text "<b><u>#{tc.full_name.upcase}</u></b>",
              :size => 12,
              :inline_format => true
          elsif ['ORDER','FAMILY'].include? tc.rank_name
            pdf.formatted_text [
              {
                :text => tc.full_name.upcase,
                :styles => [:bold],
                :size => 10
              },
              {
                :text =>
                  unless tc.english.blank? || 
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
          else
            omit_listing = false
          end
        end#unless prev_id != current_id
        #filter out deletion records that were added programatically to simplify
        #current listing calculations
        omit_listing = true if tc.change_type == ChangeType::DELETION && !tc.species_listing.nil?
        #filter out null records for higher taxa
        omit_listing = true if tc.change_type.blank?
        unless omit_listing
          listing_modifier = if tc.change_type == ChangeType::RESERVATION
            "/r"
          elsif tc.change_type == ChangeType::RESERVATION_WITHDRAWAL
            "/w"
          elsif tc.change_type == ChangeType::DELETION
            "/Del"
          else
            nil
          end
          listings_table << [
            "<i>#{omit_name ? nil : tc.full_name}</i>",
            "#{tc.species_listing}#{listing_modifier}",
            "#{tc.party}".upcase,
            "#{tc.effective_at ? Time.new(tc.effective_at).strftime("%d/%m/%y") : nil}",
            "#{tc.listing_notes}".sub(/NULL/,'')#TODO
          ]
        end
        omit_name = true
      end
    end
  end

end