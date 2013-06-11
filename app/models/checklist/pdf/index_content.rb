# TODO replace rank name strings with constants from the Rank model
# or better yet, define methods such as "ranks_below_family"
# in the rank class to clean up the code here
module Checklist::Pdf::IndexContent

  def content(tex)
    fetcher = Checklist::Pdf::IndexFetcher.new(@animalia_query)
    kingdom(tex, fetcher, 'FAUNA')
    fetcher = Checklist::Pdf::IndexFetcher.new(@plantae_query)
    kingdom(tex, fetcher, 'FLORA')
    tex << annotations_key
  end

  def annotations_key
    tex = "\\parindent 0in"
    tex << "\\cpart{Annotations key}\n"
    listing_changes_with_index_annotations = MListingChange.
      includes(:taxon_concept).
      where(:is_current => true, :display_in_index => true, :designation_name => Designation::CITES).
      where("ann_symbol IS NOT NULL").
      order(:"ann_symbol::INT")

    tex << "\\section*{Annotations not preceded by \"\\#\"}\n"
    listing_changes_with_index_annotations.each do |lc|
        box_colour = (lc.taxon_concept.kingdom_name == 'Animalia' ? 'orange' : 'green')
        tex << "\\cfbox{#{box_colour}}{\\superscript{#{lc.ann_symbol}} \\textbf{#{taxon_name_at_rank(lc.taxon_concept)}}}\n\n"
        tex << "#{LatexToPdf.html2latex(lc.full_note_en)}\n\n"
      end
    tex << "\\parindent -0.1in"
    tex
  end

  def kingdom(tex, fetcher, kingdom_name)
    kingdom = fetcher.next
    return if kingdom.empty?
    tex << "\\cpart{#{kingdom_name}}\n"
    tex << "\\begin{multicols}{2}{" #start multicols
    begin
      entries = kingdom.map do |tc|
        if tc.read_attribute(:name_type) == 'synonym'
          synonym_entry(tc)
        elsif tc.read_attribute(:name_type) == 'common'
          common_name_entry(tc)
        else
          main_entry(tc)
        end
      end
      tex << entries.join("\n\n")
      kingdom = fetcher.next
    end while not kingdom.empty?
    tex << '}\\end{multicols}' #end multicols
  end

  def synonym_entry(tc)
    res = "\\textit{#{LatexToPdf.escape_latex(tc.sort_name)} = #{tc.full_name}}"
    res += " \\textit{#{LatexToPdf.escape_latex(tc.author_year)}}" if @authors
    res
  end

  def common_name_entry(tc)
    "#{LatexToPdf.escape_latex(tc.sort_name)} (#{tc.lng.upcase}): \\textit{#{tc.full_name}}"
  end

  def main_entry(tc)
    res = listed_taxon_name(tc)
    res += " \\textit{#{LatexToPdf.escape_latex(tc.author_year)}}" if @authors
    res += current_listing_with_annotations(tc)
    if ['SPECIES', 'SUBSPECIES', 'GENUS', 'FAMILY', 'SUBFAMILY'].include? tc.rank_name
      res += " #{"#{tc.family_name}".upcase}" if tc.rank_name != 'FAMILY'
      res += " (#{tc.class_name})" unless tc.class_name.blank?
    end
    res += common_names_with_lng_initials(tc)
    res
  end

  def taxon_name_at_rank(taxon_concept)
    res = if ['FAMILY','SUBFAMILY','ORDER','CLASS'].include? taxon_concept.rank_name
      LatexToPdf.escape_latex(taxon_concept.full_name.upcase)
    else
      if ['SPECIES', 'SUBSPECIES', 'GENUS'].include? taxon_concept.rank_name
        "\\textit{#{LatexToPdf.escape_latex(taxon_concept.full_name)}}"
      else
        LatexToPdf.escape_latex(taxon_concept.full_name)
      end
    end
    res += " #{LatexToPdf.escape_latex(taxon_concept.spp)}" if taxon_concept.spp
    res
  end

  def listed_taxon_name(taxon_concept)
    res = taxon_name_at_rank(taxon_concept)
    "\\textbf{#{res}}" if taxon_concept.cites_accepted
    res
  end

  def current_listing_with_annotations(taxon_concept)
    res = " \\textbf{#{taxon_concept.current_listing}} "
    unless taxon_concept.hash_ann_symbol.blank?
      symbol = LatexToPdf.escape_latex(taxon_concept.hash_ann_symbol)
      res = " #{symbol}#{res}"
    end
    unless taxon_concept.ann_symbol.blank?
      res += "\\superscript{#{taxon_concept.ann_symbol}}"
    end
    res
  end

end
