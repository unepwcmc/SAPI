class Checklist::PdfIndexKingdom
  def initialize(pdf, query, kingdom_display_name)
    @pdf = pdf
    @query = query
    @kingdom_display_name = kingdom_display_name
  end

  def to_pdf
    pdf = @pdf
    limit = 5000
    offset = 0
    pdf.text(@kingdom_display_name, :size => 12, :align => :center)

    @indent = 15
    pdf.column_box([0, pdf.cursor], :columns => 2, :width => pdf.bounds.width) do

      begin

      #fetch data
      kingdom = MTaxonConcept.find_by_sql(
        @query.to_sql(limit, offset)
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