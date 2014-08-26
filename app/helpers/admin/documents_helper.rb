module Admin::DocumentsHelper

  def document_citations_tooltip(document)
    content_tag(:ul) do
      document.citations.each do |citation|
        text = if citation.taxon_concepts.empty?
          citation.geo_entities.map(&:name_en).join(', ')
        elsif citation.geo_entities.empty?
          citation.taxon_concepts.map(&:full_name).join(', ')
        else
          citation.taxon_concepts.map(&:full_name).join(', ') +
          ' / ' +
          citation.geo_entities.map(&:name_en).join(', ')
        end
        concat content_tag(:li, text)
      end
    end
  end

end
