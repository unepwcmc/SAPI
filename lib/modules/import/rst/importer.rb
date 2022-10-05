module Import::Rst::Importer
  class << self

    def import(data)
      data.map do |item|
        taxon_concept = map_taxon_concept(item)
        geo_entity    = map_geo_entity(item)
        event         = map_event(item)

        rst_process   = CitesRstProcess.find_or_initialize_by(case_id: item['id'])
        Rails.logger.info "Importing RST case #{item['id']}..."
        rst_process.update!(
          taxon_concept: taxon_concept,
          geo_entity: geo_entity,
          event: event,
          status: item['status'],
          start_date: item['startDate'],
          resolution: 'Significant Trade'
        )
      end

      private

      def map_taxon_concept(item)
        taxon_concept = MTaxonConcept.find_by(taxonomy_id: 1, full_name: item['species']['name'])
        unless taxon_concept
          Rails.logger.info "Species #{item['species']['name']} for case #{item['id']} not found, skipping... "
          next
        end
      end

      def map_geo_entity(item)
        geo_entity = GeoEntity.find_by(iso_2: item['country_iso2'])
        unless geo_entity
          Rails.logger.info "Country #{item['country_iso2']} for case #{item['id']} not found, skipping... "
          next
        end
      end

      def map_event(item)
        event = Event.where("type IN (:event_type) AND name :event_name",
          event_type: ['CitesAc', 'CitesPc'], event_name: item['meeting']['name'])
        Rails.logger.info "Event #{item['meeting']['name']} for case #{item['id']} not found" unless event
      end
    end
  end
end
