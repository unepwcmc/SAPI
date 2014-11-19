class Api::V2::EuLegislationController < ApplicationController
  resource_description do
    formats ['json']
    api_base_url 'api/v2/taxon_concepts'
  end

  api :GET, '/:id/eu_legislation', "Lists current listings, opinions, and suspensions for a given taxon concept"
  param :id, Integer, :desc => "Taxon Concept ID", :required => true
  example <<-EOS
    'eu_legislation': [
      {
        'eu_listings' : [
          {
            'is_current' : true,
            'species_listing_name' : 'I',
            'party_full_name' : null,
            'effective_at_formatted' : '13/09/2007',
            'short_note_en' : 'All populations except those of BW, NA, ZA, and ZW.',
            'full_note_en' : 'Included in Appendix I except the population...',
            'auto_note' : null,
            'is_inclusion' : null,
            'subspecies_info' : null,
            'inherited_full_note_en' : null,
            'inherited_short_note_en' : null,
            'event_name' : 'Commission Reg. (EU)',
            'event_url' : 'http://eur-lex.europa.eu/LexUriServ/',
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