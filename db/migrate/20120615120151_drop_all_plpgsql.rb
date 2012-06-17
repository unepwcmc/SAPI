class DropAllPlpgsql < ActiveRecord::Migration
  def change
    execute "DROP TYPE IF EXISTS listing_change_extended CASCADE"
    execute "DROP TYPE IF EXISTS taxon_concept_with_ancestors CASCADE"
    execute "DROP TRIGGER IF EXISTS taxon_concept_insert_trigger ON taxon_concepts"
    execute "DROP TRIGGER IF EXISTS taxon_concept_update_trigger ON taxon_concepts"
    execute "DROP FUNCTION IF EXISTS update_taxonomic_position(integer)"
    execute "DROP FUNCTION IF EXISTS get_ancestor_taxonomic_position(integer, integer)"
    execute "DROP FUNCTION IF EXISTS get_cites_listing(taxon_concepts)"
    execute "DROP FUNCTION IF EXISTS get_full_name(character varying, character varying, character varying, character varying)"
    execute "DROP FUNCTION IF EXISTS taxon_concept_with_ancestors(param_id integer)"
    execute "DROP FUNCTION IF EXISTS update_taxon_concept_hstore_trigger()"
    execute "DROP FUNCTION IF EXISTS tmp()"
    execute "DROP FUNCTION IF EXISTS tmp(integer)"
  end
end
