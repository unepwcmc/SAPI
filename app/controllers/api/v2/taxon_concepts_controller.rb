class Api::V2::TaxonConceptsController < ApplicationController
  resource_description do
    formats ['JSON']
    api_base_url 'api/v2/taxon_concepts'
    name 'Taxon Concepts'
  end

  api :GET, '/', 'Lists taxon concepts'
  param :page, Integer, desc: 'Page Number', required: false
  param :updated_since, Time, required: false
  example <<-EOS
    'taxon_concepts': [
      {
        'id': 4521,
        'scientific_name': 'Loxodonta africana',
        'author_year': '(Blumenbach, 1797)',
        'rank': 'SPECIES',
        'name_status': 'A',
        'higher_taxa': {
          'genus': 'Loxodonta',
          'family': 'Elephantidae',
          'order': 'Proboscidea',
          'class': 'Mammalia',
          'phylum': 'Chordata'
        },
        'synonyms': [
          {
            id: 37069,
            scientific_name: 'Loxodonta cyclotis',
            author_year: '(Matschie, 1900)'
          }
        ]
      }
    ]
  EOS

  def index
  end
end
