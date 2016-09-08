module Checklist::Json::HistoryContent

  def content(json_file)
    json_file << @taxon_concepts_rel.active_model_serializer.new(
      @taxon_concepts_rel,
      :each_serializer => Checklist::HistoryTaxonConceptSerializer,
      :authors => @authors
    ).to_json
  end

end
