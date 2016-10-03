require 'rubygems'
require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'https://speciesplus.net'
SitemapGenerator::Sitemap.create do
  add '/about', changefreq: 'yearly'
  add '/terms-of-use', changefreq: 'yearly'
  add '/eu_legislation', changefreq: 'yearly'
  add '/#/elibrary', changefreq: 'yearly'
  MTaxonConcept.where(show_in_species_plus: true).pluck(:id).each do |tc_id|
    add "/#/taxon_concepts/#{tc_id}/legal", changefreq: 'monthly'
  end
end
