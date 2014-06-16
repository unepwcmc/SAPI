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

        #analyse mapping
      end
    end

    def analyse mapping
      species = JSON.parse(RestClient.get(@show_url+"mapping.cms_taxon_name"))
      debugger
      true
    end
  end
end
