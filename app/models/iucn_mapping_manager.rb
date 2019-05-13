class IucnMappingManager

  class << self

    def sync
      species = Rank.where(:name => Rank::SPECIES).first
      @subspecies = Rank.where(:name => Rank::SUBSPECIES).first
      taxonomy = Taxonomy.where(:name => Taxonomy::CITES_EU).first

      TaxonConcept.where(:rank_id => [species.id, @subspecies.id], :name_status => ['A', 'S'],
                         :taxonomy_id => taxonomy.id).each do |taxon_concept|
        sync_taxon_concept taxon_concept
      end
    end

    def sync_taxon_concept(taxon_concept)
      mapping = IucnMapping.find_or_create_by(taxon_concept_id: taxon_concept.id)
      full_name = if taxon_concept.rank_id == @subspecies.id
                    taxon_concept.full_name.insert(taxon_concept.full_name.rindex(/ /), " ssp.")
                  else
                    taxon_concept.full_name
                  end
      data = fetch_data_for_name full_name
      if !data || !data["result"] || data["result"].empty?
        puts "#{taxon_concept.full_name} NO MATCH"
      else
        map_taxon_concept taxon_concept, mapping, data
      end
    end

    def fetch_data_for_name(full_name)
      @config_location ||= Rails.root.join('config/secrets.yml')
      @config ||= YAML.load_file(@config_location)[Rails.env]
      @token ||= @config['iucn_redlist']['token']
      @url ||= @config['iucn_redlist']['url']
      puts "#{@url}#{full_name.downcase}?token=#{@token}"
      url = URI.escape("#{@url}#{full_name.downcase}?token=#{@token}")
      JSON.parse(RestClient.get(url))
    end

    def map_taxon_concept(taxon_concept, map, data)
      begin
        match = data["result"].first
        puts "#{taxon_concept.full_name} #{taxon_concept.author_year} <=>  #{match["scientific_name"]} #{match["authority"]}"
        map.update_attributes(
          :iucn_taxon_name => match['scientific_name'],
          :iucn_taxon_id => match['taxonid'],
          :iucn_author => match['authority'],
          :iucn_category => match['category'],
          :details => {
            :match => type_of_match(taxon_concept, match),
            :no_matches => data["result"].size
          },
          :accepted_name_id => taxon_concept.name_status == 'S' ? taxon_concept.accepted_names.first.try(:id) : nil
        )
      rescue Exception => e
        puts "#######################################################################"
        puts "########################## EXCEPTION Taxon Concept #{taxon_concept.id} ###########"
        puts e.message
      end
    end

    def type_of_match(tc, match)
      if tc.full_name == match["scientific_name"]
        if strip_authors(tc.author_year) == strip_authors(match["authority"])
          puts "FULL_MATCH!"
          "FULL_MATCH"
        else
          puts "NAME_MATCH"
          "NAME_MATCH"
        end
      end
    end

    def strip_authors(author)
      return '' unless author
      author.split(" ").
        reject { |p| ["and", "&", "&amp;", ","].include?(p) }.
        join(" ")
    end
  end
end
