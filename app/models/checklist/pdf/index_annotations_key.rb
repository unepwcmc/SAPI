class Checklist::Pdf::IndexAnnotationsKey
  include Checklist::Pdf::Helpers

  def annotations_key
    tex = "\\newpage\n"
    tex << "\\parindent 0in"
    tex << "\\cpart{\\annotationsKey}\n"
    tex << non_hash_annotations_key
    tex << hash_annotations_key
    tex << "\\parindent -0.1in"
    tex
  end

  def non_hash_annotations_key
    tex = "\\section*{\\nonHashAnnotations}\n"
    non_hash_annotations.each do |a|
      box_colour = (a[:taxon_concept].kingdom_name == 'Animalia' ? 'orange' : 'green')
      tex << "\\cfbox{#{box_colour}}{\\superscript{#{a[:symbol]}} \\textbf{#{taxon_name_at_rank(a[:taxon_concept])}}}\n\n"
      tex << "#{LatexToPdf.html2latex(a[:note])}\n\n"
    end
    tex
  end

  def hash_annotations_key
    tex = "\\newpage\n"
    tex << "\\section*{\\hashAnnotations}\n"
    tex << "\\hashAnnotationsIndexInfo" + "\n\n"
    cop = CitesCop.find_by_is_current(true)
    annotations = cop && cop.hash_annotations.order('SUBSTRING(symbol FROM 2)::INT')
    unless annotations && !annotations.empty?
      tex << "No current hash annotations found.\n\n"
      return tex
    end

    tex << "\\hashannotationstable{\n\\rowcolor{pale_aqua}\n"
    tex << "#{LatexToPdf.escape_latex(cop.name)} & \\validFrom \\hspace{2 pt} #{cop.effective_at_formatted}\\\\\n"
    annotations.each do |a|
      tex << "#{LatexToPdf.escape_latex(a.symbol)} & #{LatexToPdf.html2latex(a.full_note)} \\\\\n\n"
    end
    tex << "}\n"
    tex
  end

  private

  def non_hash_annotations
    MCitesListingChange.
      joins(:taxon_concept).
      includes(:taxon_concept).
      where(
        :is_current => true,
        :display_in_index => true
      ).
      where('taxon_concept_id = original_taxon_concept_id').
      where('cites_listing_changes_mview.ann_symbol IS NOT NULL').
      order("cites_listing_changes_mview.ann_symbol::INT").map do |lc|
        {
          :taxon_concept => lc.taxon_concept,
          :symbol => lc.ann_symbol,
          :note => lc.full_note
        }
      end
  end

end
