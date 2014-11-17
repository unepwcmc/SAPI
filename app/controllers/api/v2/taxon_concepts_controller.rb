class Api::V2::TaxonConceptsController < ApplicationController

  resource_description do
    formats ['json']
    api_base_url 'api/v2/taxon_concepts'

    description <<-EOS
      My controller description.
    EOS
  end

  api :GET, '/', "List of taxon concepts"
  param :page, Integer, :desc => "Page number"
  description "Provides a paginated list of taxon concepts, with
    100 records per page"
  example <<-EOS
    'taxon_concepts': [
      {
        'id': 1,
        'scientific_name': 'Loxodonta africana',
        'author_year': '(Blumenbach, 1797)',
        'rank': 'SPECIES',
      }
    ]
  EOS
  def index
  end
end
