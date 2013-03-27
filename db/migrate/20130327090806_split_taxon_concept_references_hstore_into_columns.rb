class SplitTaxonConceptReferencesHstoreIntoColumns < ActiveRecord::Migration
  def change
    add_column :taxon_concept_references, :is_standard, :boolean
    add_column :taxon_concept_references, :is_cascaded, :boolean
    add_column :taxon_concept_references, :excluded_taxon_concepts_ids, 'INTEGER[]'
    Sapi::disable_triggers
    execute <<-SQL
    UPDATE taxon_concept_references SET
    is_standard = COALESCE((data->'usr_is_std_ref')::BOOLEAN, FALSE),
    is_cascaded = COALESCE((data->'cascade')::BOOLEAN, TRUE),
    excluded_taxon_concepts_ids = (data->'exclusions')::INT[]
    SQL
    Sapi::enable_triggers
    change_column :taxon_concept_references, :is_standard, :boolean, :null => false, :default => false
    change_column :taxon_concept_references, :is_cascaded, :boolean, :null => false, :default => false
    remove_column :taxon_concept_references, :data
  end
end
