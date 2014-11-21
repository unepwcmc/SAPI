class Api::V2::NamesController < ApplicationController
  resource_description do
    formats ['JSON']
    api_base_url 'api/v2/taxon_concepts'
  end

  api :GET, '/:id/names', "Lists synonyms and common names for a given taxon concept"
  param :id, Integer, :desc => "Taxon Concept ID", :required => true
  example <<-EOS
    'synonyms': [
      {
        'id': 1,
        'scientific_name': 'Loxodonta africana'
      }
    ],
    'common_names': [
      {
        'id': 1,
        'scientific_name': 'Loxodonta africana'
      }
    ]
  EOS
  
  def index
  end
end
