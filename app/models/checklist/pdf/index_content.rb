module Checklist::Pdf::IndexContent

  def content(tex)
    fetcher = Checklist::Pdf::IndexFetcher.new(@animalia_query)
    kingdom(tex, fetcher, 'FAUNA')
    fetcher = Checklist::Pdf::IndexFetcher.new(@plantae_query)
    kingdom(tex, fetcher, 'FLORA')
  end

  def kingdom(tex, fetcher, kingdom_name)
    kingdom = fetcher.next
    return if kingdom.empty?
    tex << "\\cpart{#{kingdom_name}}\n"
    tex << "\\begin{multicols}{2}{" #start multicols
    begin
      kingdom.each do |tc|
        entry = 
        if tc.read_attribute(:name_type) == 'synonym'
          #it's a synonym or common name entry
          "\\textit{#{tc.sort_name} = #{tc.full_name}}"
        elsif tc.read_attribute(:name_type) == 'common'
          "#{tc.sort_name} (#{tc.lng.upcase}): \\textit{#{tc.full_name}}"
        else
          res = if ['FAMILY','ORDER','CLASS'].include? tc.rank_name
            tc.full_name.upcase
          else
            tc.full_name
          end
          res = "\\textit{#{res}}" if ['SPECIES', 'SUBSPECIES', 'GENUS'].include? tc.rank_name
          res = "#{res} #{tc.spp}"
          res = "\\textbf{#{res}}" if tc.cites_accepted
          res += " #{tc.generic_annotation_symbol}" unless tc.generic_annotation_symbol.blank?
          res += " \\textbf{#{tc.current_listing}} "
          res += "\\superscript{#{tc.specific_annotation_symbol}}" unless tc.specific_annotation_symbol.blank?
          res += " #{"#{tc.family_name}".upcase}"
          res += " (#{tc.class_name})" unless tc.class_name.blank?
          res += " (E) #{tc.english_names.join(', ')} " unless !tc.english_names_ary? || tc.english_names.empty?
          res += " (S) #{tc.spanish_names.join(', ')} " unless !tc.spanish_names_ary? || tc.spanish_names.empty?
          res += " (E) #{tc.french_names.join(', ')} " unless !tc.french_names_ary? || tc.french_names.empty?
          res
        end
        tex << entry + "\n\n"
      end
      kingdom = fetcher.next
    end while not kingdom.empty?
    tex << '}\\end{multicols}' #end multicols
  end

end