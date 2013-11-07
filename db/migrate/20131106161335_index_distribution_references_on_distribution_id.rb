class IndexDistributionReferencesOnDistributionId < ActiveRecord::Migration
  def change
    remove_index :distribution_references, :name => :index_distribution_references_on_distribution_id_and_ref_id
    add_index :distribution_references, :distribution_id
    add_index :distribution_references, :reference_id
  end
end
