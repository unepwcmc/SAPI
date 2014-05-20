class AddUpdatedByIdToTaxonCommons < ActiveRecord::Migration
  def change
    add_column :taxon_commons, :updated_by_id, :integer
  end
end
