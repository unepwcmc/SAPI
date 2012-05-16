class AddFieldsToDistribution < ActiveRecord::Migration
  def change
    add_column :distributions, :taxon_concept_id, :integer, :null => false
    add_foreign_key "distributions", "taxon_concepts", :name => "distributions_taxon_concept_id_fk"
  end
end
