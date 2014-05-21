class AddCreatedByIdToTaxonInstruments < ActiveRecord::Migration
  def change
    add_column :taxon_instruments, :created_by_id, :integer
  end
end
