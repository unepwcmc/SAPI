class Checklist::Pdf::IndexAnnotationsKey
  include Checklist::Pdf::Helpers

  def annotations_key
    tex = "\\parindent 0in"
    tex << "\\cpart{#{LatexToPdf.escape_latex(I18n.t('pdf.annotations_key'))}}\n"
    cites = Designation.find_by_name(Designation::CITES)
    full_note_field = "full_note_#{I18n.locale}"
    taxa_with_index_annotations = MTaxonConcept.
      select("taxon_concepts_mview.*, annotations.symbol, annotations.#{full_note_field}").
      joins( <<-SQL
        JOIN listing_changes
        ON listing_changes.taxon_concept_id = taxon_concepts_mview.id
        AND listing_changes.is_current
        JOIN change_types
        ON change_types.id = listing_changes.change_type_id
        AND designation_id = #{cites.id}
        AND change_types.name = 'ADDITION'
        JOIN annotations
        ON listing_changes.annotation_id = annotations.id
        AND annotations.display_in_index
        AND annotations.symbol IS NOT NULL
      SQL
      ).
      order("annotations.symbol::INT")

    tex << "\\section*{#{LatexToPdf.escape_latex(I18n.t('pdf.non_hash_annotations'))}}\n"
    taxa_with_index_annotations.each do |tc|
        box_colour = (tc.kingdom_name == 'Animalia' ? 'orange' : 'green')
        tex << "\\cfbox{#{box_colour}}{\\superscript{#{tc['symbol']}} \\textbf{#{taxon_name_at_rank(tc)}}}\n\n"
        tex << "#{LatexToPdf.html2latex(tc[full_note_field])}\n\n"
      end
    tex << "\\parindent -0.1in"
    tex
  end

end