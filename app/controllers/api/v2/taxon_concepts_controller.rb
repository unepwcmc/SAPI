class Api::V2::TaxonConceptsController < ApplicationController
  resource_description do
    formats ['json']
    api_base_url 'api/v2/taxon_concepts'
  end

  api :GET, '/', "Lists taxon concepts"
  param :page, Integer, :desc => "Page Number", :required => false
  example <<-EOS
    'taxon_concepts': [
      {
        'id': 1,
        'scientific_name': 'Loxodonta africana',
        'author_year': '(Blumenbach, 1797)',
        'rank': 'SPECIES'
      }
    ]
  EOS
  
  def index
  end
end
