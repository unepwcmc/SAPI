class ReaddAncestorsIdsAsIntegersToTaxonConceptsMview < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "kingdom_id" TYPE integer USING (kingdom_id)::INTEGER'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "phylum_id" TYPE integer USING (phylum_id)::INTEGER'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "class_id" TYPE integer USING (class_id)::INTEGER'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "order_id" TYPE integer USING (order_id)::INTEGER'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "family_id" TYPE integer USING (family_id)::INTEGER'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "genus_id" TYPE integer USING (genus_id)::INTEGER'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "species_id" TYPE integer USING (species_id)::INTEGER'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "subspecies_id" TYPE integer USING (subspecies_id)::INTEGER'
  end
  def down
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "kingdom_id" TYPE VARCHAR USING (kingdom_id)::VARCHAR'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "phylum_id" TYPE VARCHAR USING (phylum_id)::VARCHAR'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "class_id" TYPE VARCHAR USING (class_id)::VARCHAR'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "order_id" TYPE VARCHAR USING (order_id)::VARCHAR'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "family_id" TYPE VARCHAR USING (family_id)::VARCHAR'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "genus_id" TYPE VARCHAR USING (genus_id)::VARCHAR'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "species_id" TYPE VARCHAR USING (species_id)::VARCHAR'
    execute 'ALTER TABLE "taxon_concepts_mview" ALTER COLUMN "subspecies_id" TYPE VARCHAR USING (subspecies_id)::VARCHAR'
  end
end
