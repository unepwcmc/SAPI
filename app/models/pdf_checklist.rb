class PdfChecklist < Checklist

  def generate
    Prawn::Document.new do |pdf|
      pdf.text "CITES CHECKLIST", :align => :center, :size => 18
      pdf.move_down 12

      pdf.column_box([0, pdf.cursor], :columns => 2, :width => pdf.bounds.width) do
        @taxon_concepts_rel.each do |tc|
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

end