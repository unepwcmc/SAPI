class AddUpdatedByIdToTaxonInstruments < ActiveRecord::Migration
  def change
    add_column :taxon_instruments, :updated_by_id, :integer
  end
end
