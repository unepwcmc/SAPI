class AddCreatedByIdToTaxonCommons < ActiveRecord::Migration
  def change
    add_column :taxon_commons, :created_by_id, :integer
  end
end
