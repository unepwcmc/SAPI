module Checklist::Json::IndexContent

  def content(json_file)
    json_file << @taxon_concepts_rel.active_model_serializer.new(
      @taxon_concepts_rel, 
      :each_serializer => Checklist::IndexTaxonConceptSerializer,
      :authors => @authors,
      :synonyms => @synonyms,
      :english_names => @english_names,
      :spanish_names => @spanish_names,
      :french_names => @french_names
    ).to_json    
  end

end