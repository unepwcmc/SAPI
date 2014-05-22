#require 'uri'
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
                       :taxonomy_id => taxonomy.id).limit(200).each do |tc|
      url = URI.escape("#{API_URL}#{tc.full_name.downcase}?token=#{token}")
      data = JSON.parse(RestClient.get(url))
      begin
        unless data["result"].empty?
          puts "#{tc.full_name} #{tc.author_year} <=>  #{data["name"]} #{data["result"].first["authority"]}"
        else
          puts "#{tc.full_name} NO MATCH"
        end
      rescue
        puts "CABOOM: #{data.inspect}"
      end
    end
  end
end
