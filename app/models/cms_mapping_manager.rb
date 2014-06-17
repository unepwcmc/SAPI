class CmsMappingManager

  class << self

    def sync
      config_location ||= Rails.root.join('config/secrets.yml')
      @config = YAML.load_file(config_location)[Rails.env]
      index_url = @config['cms']['index']
      @show_url = @config['cms']['show']
      puts "#{index_url}"
      url = URI.escape(index_url)
      cms = Taxonomy.where(:name => Taxonomy::CMS).first
      species = JSON.parse(RestClient.get(url))
      species.each do |sp|
        taxon_concept = TaxonConcept.where(:full_name => sp["scientific_name"],
                                           :taxonomy_id => cms.id).first
        mapping = CmsMapping.find_or_create_by_taxon_concept_id_and_cms_taxon_name_and_cms_uuid(
          taxon_concept.try(:id), sp["scientific_name"], sp["node_uuid"])

        analyse mapping
      end
    end

    def analyse mapping
      url = URI.escape(@show_url+mapping.cms_taxon_name)
      species = JSON.parse(RestClient.get(url)).first
      if species
        puts "setting mapping details for #{mapping.cms_taxon_name}"
        mapping.cms_author = species["taxonomy"]["author"]
        mapping.details = {
          :distributions_splus => mapping.taxon_concept && mapping.taxon_concept.distributions.size,
          :distributions_cms => species["geographic_range"]["range_states"].size
        }
        mapping.save
      end
    end
  end
end
