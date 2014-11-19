class Api::V2::ReferencesController < ApplicationController
  resource_description do
    formats ['json']
    api_base_url 'api/v2/taxon_concepts'
  end

  api :GET, '/:id/references', "Lists references for a given taxon concept"
  param :id, Integer, :desc => "Taxon Concept ID", :required => true
  
  def index
  end
end