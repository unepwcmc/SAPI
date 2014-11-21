class Api::V2::CitesLegislationController < ApplicationController
  resource_description do
    formats ['JSON']
    api_base_url 'api/v2/taxon_concepts'
    name 'CITES Legislation'
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
            'appendix' : 'I',
            'party_full_name' : null,
            'effective_at_formatted' : '13/09/2007',
            'short_note_en' : 'All populations except those of BW, NA, ZA, and ZW.',
            'full_note_en' : 'Included in Appendix I except the population...',
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
        ],
        'cites_quotas' : [
          {
            'quota' : 0,
            'year' : '2014',
            'publication_date' : '14/03/2014',
            'notes' : 'raw ivory',
            'url' : 'http://www.cites.org/common/quotas/2013/ExportQuotas2013.pdf',
            'public_display' : true,
            'is_current' : true,
            'unit_name' : '',
            'subspecies_info' : null,
            'geo_entity' : {
              'id' : 105,
              'name' : 'Angola',
              'iso_code2' : 'AO',
              'geo_entity_type' : 'COUNTRY'
            }
          }
        ],
        'cites_suspensions' : [
          {
            'notes' : 'All trade in specimens of CITES-listed species',
            'start_date' : '13/10/2014',
            'is_current' : true,
            'subspecies_info' : null
            'geo_entity' : {
              'id' : 49,
              'name' : 'Gambia',
              'iso_code2' : 'GM',
              'geo_entity_type' : 'COUNTRY'
            },
            'start_notification' : {
              'name' : 'CITES Notif. No. 2014/046',
              'effective_at_formatted' : '13/10/2014',
              'url' : 'http://cites.org/sites/default/files/notif/E-Notif-2014-046.pdf'
            }
          }
        ]
      }
    ]
  EOS
  
  def index
  end
end
