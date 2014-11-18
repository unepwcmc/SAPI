class Api::V2::DistributionsController < ApplicationController

  resource_description do
    formats ['json']
  end

  api :GET, '/taxon_concepts/:taxon_concept_id/distributions',
    'Lists a taxon concepts distribution information'
  param :taxon_concept_id, Integer, :desc => "Taxon concept's id",
    :required => true
  def index
  end
end
