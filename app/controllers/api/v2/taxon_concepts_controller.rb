class Api::V2::TaxonConceptsController < ApplicationController

  resource_description do
    formats ['json']
    api_base_url 'api/v2/taxon_concepts'

    description <<-EOS
      == About the API
      == Authenticating your requests
      == Pagination
      == Contact
    EOS
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
  def show
  end

  api :GET, '/:id/cites_legislation', "Lists current listings, quotas, and suspensions for a given taxon concept"
  param :id, Integer, :desc => "Taxon Concept ID", :required => true
  def show2
  end

  api :GET, '/:id/eu_legislation', "Lists current listings, opinions, and suspensions for a given taxon concept"
  param :id, Integer, :desc => "Taxon Concept ID", :required => true
  def show3
  end

  api :GET, '/:id/references', "Lists references for a given taxon concept"
  param :id, Integer, :desc => "Taxon Concept ID", :required => true
  def show4
  end

  api :GET, '/:id/distributions', "Lists distributions for a given taxon concept"
  param :id, Integer, :desc => "Taxon Concept ID", :required => true
  def show5
  end
end
