# TODO replace rank name strings with constants from the Rank model
# or better yet, define methods such as "ranks_below_family"
# in the rank class to clean up the code here
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
          res = listed_taxon_name(tc)
          res += current_listing_with_annotations(tc)
          if ['SPECIES', 'SUBSPECIES', 'GENUS', 'FAMILY'].include? tc.rank_name
            res += " #{"#{tc.family_name}".upcase}" if tc.rank_name != 'FAMILY'
            res += " (#{tc.class_name})" unless tc.class_name.blank?
          end
          res += common_names_with_lng_initials(tc)
          res
        end
        tex << entry + "\n\n"
      end
      kingdom = fetcher.next
    end while not kingdom.empty?
    tex << '}\\end{multicols}' #end multicols
  end

  def listed_taxon_name(taxon_concept)
    res = if ['FAMILY','ORDER','CLASS'].include? taxon_concept.rank_name
      taxon_concept.full_name.upcase
    else
      if ['SPECIES', 'SUBSPECIES', 'GENUS'].include? taxon_concept.rank_name
        "\\textit{#{taxon_concept.full_name}}"
      else
        taxon_concept.full_name
      end
    end
    res += " #{taxon_concept.spp}" if taxon_concept.spp
    res = "\\textbf{#{res}}" if taxon_concept.cites_accepted
    res
  end

  def current_listing_with_annotations(taxon_concept)
    res = " \\textbf{#{taxon_concept.current_listing}} "
    unless taxon_concept.generic_annotation_symbol.blank?
      res = " #{taxon_concept.generic_annotation_symbol}#{res}"
    end
    unless taxon_concept.specific_annotation_symbol.blank?
      res += "\\superscript{#{taxon_concept.specific_annotation_symbol}}"
    end
    res
  end

  def common_names_with_lng_initials(taxon_concept)
    res = ''
    unless !@english_common_names || taxon_concept.english_names.empty?
      res += " (E) #{taxon_concept.english_names.join(', ')} "
    end
    unless !@spanish_common_names || taxon_concept.spanish_names.empty?
      res += " (S) #{taxon_concept.spanish_names.join(', ')} "
    end
    unless !@french_common_names || taxon_concept.french_names.empty?
      res += " (E) #{taxon_concept.french_names.join(', ')} "
    end
    res
  end

end