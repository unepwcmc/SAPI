class MoveNotInCitesToListing < ActiveRecord::Migration
  def change
    remove_column :taxon_concepts, :not_in_cites
  end
end
