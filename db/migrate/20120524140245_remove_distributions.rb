class RemoveDistributions < ActiveRecord::Migration
  def up
    remove_foreign_key "distribution_components", :name => "distribution_components_distribution_id_fk"
    drop_table :distribution_components
    remove_foreign_key "distributions", :name => "distributions_taxon_concept_id_fk"
    drop_table :distributions
  end

  def down
  end
end
