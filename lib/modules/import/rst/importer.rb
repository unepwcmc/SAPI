module Import::Rst::Importer
  class << self

    def import(data)
      data.map do |item|
        taxon_concept = map_taxon_concept(item)
        unless taxon_concept
          Rails.logger.error "Species #{item['species']['name']} for case #{item['id']} not found, skipping... "
          next
        end

        geo_entity = map_geo_entity(item)
        unless geo_entity
          Rails.logger.error "Country #{item['country_iso2']} for case #{item['id']} not found, skipping... "
          next
        end

        event = map_event(item)

        rst_process = CitesRstProcess.find_or_initialize_by(case_id: item['id'])
        action = rst_process.id ? 'Updating' : 'Importing'
        Rails.logger.info "#{action} RST process with case_id #{item['id']}..."

        rst_process.update!(
          taxon_concept_id: taxon_concept.id,
          geo_entity_id: geo_entity.id,
          start_event_id: event.try(:id),
          status: item['status'],
          start_date: item['startDate']
        )
      end
    end

    private

    def map_taxon_concept(item)
      MTaxonConcept.find_by(taxonomy_id: 1, full_name: item['species']['name'])
    end

    def map_geo_entity(item)
      GeoEntity.find_by(iso_code2: item['country_iso2'])
    end

    def map_event(item)
      event = Event.where("type IN (:event_type) AND name = :event_name",
        event_type: ['CitesAc', 'CitesPc'], event_name: item['meeting']['name']).first

      Rails.logger.info "Event #{item['meeting']['name']} for case #{item['id']} not found" unless event
      event
    end
  end
end
