class Checklist::Pdf::HistoryAnnotationsKey
  include Checklist::Pdf::Helpers

  def annotations_key
    tex = "\\newpage\n"
    tex << "\\parindent 0in"
    tex << "\\cpart{\\historicalSummaryOfAnnotations}\n"
    tex << hash_annotations_key
    tex << "\\parindent -0.1in"
    tex
  end

  def hash_annotations_key
    tex = "\\hashAnnotationsHistoryInfo" + "\n\n"
    cops = CitesCop.order('effective_at')
    cops.each do |cop|
      annotations = cop.hash_annotations.order('SUBSTRING(symbol FROM 2)::INT')
      if annotations.empty?
        tex << "No hash annotations found.\n\n"
      end

      tex << "\\hashannotationstable{\n\\rowcolor{pale_aqua}\n"
      tex << "#{LatexToPdf.escape_latex(cop.name)} & \\validFrom \\hspace{2 pt} #{cop.effective_at_formatted}\\\\\n"
      annotations.each do |a|
        tex << "#{LatexToPdf.escape_latex(a.symbol)} & #{LatexToPdf.html2latex(a.full_note)} \\\\\n\n"
      end
      tex << "}\n"
    end
    tex
  end

end
