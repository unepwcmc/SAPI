class Api::V2::ReferencesController < ApplicationController
  resource_description do
    formats ['JSON']
    api_base_url 'api/v2/taxon_concepts'
  end

  api :GET, '/:id/references', 'Lists references for a given taxon concept'
  param :id, Integer, desc: 'Taxon Concept ID', required: true
  example <<-EOS
    'references': [
      {
        'citation': 'Barnes, R. F., Agnagna, M., Alers, M. P. T.',
        'is_standard' : false
      }
    ]
  EOS

  def index
  end
end
