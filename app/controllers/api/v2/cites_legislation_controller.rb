class Api::V2::CitesLegislationController < ApplicationController
  resource_description do
    formats ['json']
    api_base_url 'api/v2/taxon_concepts'
  end

  api :GET, '/:id/cites_legislation', "Lists current listings, quotas, and suspensions for a given taxon concept"
  param :id, Integer, :desc => "Taxon Concept ID", :required => true
  example <<-EOS
    'cites_legislation': [
      {
        'taxon_concept_id': 1,
        'cites_listings' : [
          {
            'is_current' : true,
            'species_listing_name' : 'I',
            'party_full_name' : null,
            'effective_at_formatted' : '13/09/2007',
            'short_note_en' : 'All populations except those of BW, NA, ZA, and ZW.',
            'full_note_en' : 'Included in Appendix I except the population...'
            'auto_note' : null,
            'is_inclusion' : null,
            'subspecies_info' : null,
            'inherited_full_note_en' : null,
            'inherited_short_note_en' : null,
            'change_type' : 'a',
            'is_addition' : true,
            'hash_full_note_en' : null,
            'hash_display' : ''
          }
        ]
      }
    ]
  EOS
  
  def index
  end
end