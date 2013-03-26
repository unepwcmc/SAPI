class AddIndexToDistributionReferences < ActiveRecord::Migration
  def change
    add_index :distribution_references, ["distribution_id", "reference_id"],
      :name => 'index_distribution_references_on_distribution_id_and_ref_id'
  end
end
