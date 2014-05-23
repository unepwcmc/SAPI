namespace :iucn do

  desc 'Update mapping between CITES species and IUCN species'
  task :mapping => :environment do
    API_URL = 'http://rlapiv3-beta.iucnredlist.org/api/v3/species/'

    config_location = Rails.root.join('config/secrets.yml')
    config = YAML.load_file(config_location)[Rails.env]
    token = config['iucn_redlist']

    rank = Rank.where(:name => Rank::SPECIES).first
    taxonomy = Taxonomy.where(:name => Taxonomy::CITES_EU).first

    TaxonConcept.where(:rank_id => rank.id, :name_status => 'A',
                       :taxonomy_id => taxonomy.id).each do |tc|
      map = Admin::IucnMapping.find_or_create_by_taxon_concept_id(tc.id)
      url = URI.escape("#{API_URL}#{tc.full_name.downcase}?token=#{token}")
      data = JSON.parse(RestClient.get(url))
      begin
        unless data["result"].empty?
          result = data["result"].first
          puts "#{tc.full_name} #{tc.author_year} <=>  #{result["scientific_name"]} #{result["authority"]}"
          map.update_attributes(
            :iucn_taxon_name => result['scientific_name'],
            :iucn_taxon_id => result['taxonid'],
            :iucn_author => result['authority'],
            :iucn_category => result['category']
          )
        else
          puts "#{tc.full_name} NO MATCH"
        end
      rescue
        puts "CABOOM: #{data.inspect}"
      end
    end
  end
end
