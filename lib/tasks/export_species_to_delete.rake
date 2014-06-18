namespace :export do

  task :species_to_delete => :environment do
    cites = Taxonomy.where(:name => Taxonomy::CITES_EU).first
    species = Rank.where(:name => Rank::SPECIES).first

    CSV.open('tmp/species_to_delete.csv', 'wb') do |csv|
      csv << ["ID", "Legacy id", "Kingdom", "Phylum", "Class",
              "Order", "Family", "Genus", "Species", "Full name",
              "Author year", "Name Status", "NQuotas", "N EU Opinions", "N EU Suspensions",
              "N CITES Suspensions"]
      TaxonConcept.where(:name_status => ['A', 'H'], :taxonomy_id => cites.id, :rank_id => species.id).
              joins("LEFT JOIN trade_shipments ON trade_shipments.taxon_concept_id = taxon_concepts.id OR
                    trade_shipments.reported_taxon_concept_id = taxon_concepts.id").
              joins("LEFT JOIN listing_changes ON listing_changes.taxon_concept_id = taxon_concepts.id").
              where("trade_shipments.id IS NULL AND listing_changes.id IS NULL").each do |taxon_concept|
         csv << [
           taxon_concept.id,
           taxon_concept.legacy_id,
           taxon_concept.data["kingdom_name"],
           taxon_concept.data["phylum_name"],
           taxon_concept.data["class_name"],
           taxon_concept.data["order_name"],
           taxon_concept.data["family_name"],
           taxon_concept.data["genus_name"],
           taxon_concept.data["species_name"],
           taxon_concept.full_name,
           taxon_concept.author_year,
           taxon_concept.name_status,
           taxon_concept.quotas.size,
           taxon_concept.eu_opinions.size,
           taxon_concept.eu_suspensions.size,
           taxon_concept.cites_suspensions.size
         ]
      end
    end
  end
end
