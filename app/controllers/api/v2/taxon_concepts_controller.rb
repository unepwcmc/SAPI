class Api::V2::TaxonConceptsController < ApplicationController

  resource_description do
    short 'Taxon concepts'
    formats ['json']
    api_base_url 'api/v2/taxon_concepts'
  end

  api :GET, '/'
  def index
  end
end
