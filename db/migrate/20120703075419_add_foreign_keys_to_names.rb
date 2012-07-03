class AddForeignKeysToNames < ActiveRecord::Migration
  def change
    add_foreign_key "common_names", "languages", :name => "common_names_language_id_fk"
    add_foreign_key "taxon_commons", "common_names", :name => "taxon_commons_common_name_id_fk"
    add_foreign_key "taxon_commons", "taxon_concepts", :name => "taxon_commons_taxon_concept_id_fk"
  end
end
