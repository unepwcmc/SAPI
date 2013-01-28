class CreateTaxonomies < ActiveRecord::Migration
  def change
    create_table :taxonomies do |t|
      t.string :name, :null => false, :default => 'DEAFAULT TAXONOMY'

      t.timestamps
    end
  end
end
