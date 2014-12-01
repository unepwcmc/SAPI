class Api::V2::CommonNamesController < ApplicationController
  resource_description do
    formats ['JSON']
    api_base_url 'api/v2/taxon_concepts'
  end

  api :GET, '/:id/common_names', 'Lists common names for a given taxon concept'
  param :id, Integer, desc: 'Taxon Concept ID', required: true
  param :lngs, Array, desc: 'Languages to filter by, given as iso1 codes'
  example <<-EOS
    'common_names': [
      {
        'name': 'African Elephant',
        'lng': 'EN'
      },
      {
        'name': 'Afrikanischer Elefant',
        'lng': 'DE'
      }
    ]
  EOS

  def index
  end
end
