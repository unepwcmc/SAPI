module Checklist::Pdf::Helpers

  def common_names_with_lng_initials(taxon_concept)
    res = ''
    unless !@english_common_names || taxon_concept.english_names.empty?
      res += " (E) #{LatexToPdf.escape_latex(taxon_concept.english_names.join(', '))} "
    end
    unless !@spanish_common_names || taxon_concept.spanish_names.empty?
      res += " (S) #{LatexToPdf.escape_latex(taxon_concept.spanish_names.join(', '))} "
    end
    unless !@french_common_names || taxon_concept.french_names.empty?
      res += " (F) #{LatexToPdf.escape_latex(taxon_concept.french_names.join(', '))} "
    end
    res
  end

  def taxon_name_at_rank(taxon_concept)
    res =
      if ['FAMILY', 'SUBFAMILY', 'ORDER', 'CLASS'].include? taxon_concept.rank_name
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

end
