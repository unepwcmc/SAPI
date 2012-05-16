class CreateDistributionComponents < ActiveRecord::Migration
  def change
    create_table :distribution_components do |t|
      t.references :distribution, :null => false
      t.integer :component_id, :null => false
      t.string :component_type, :null => false
      t.timestamps
    end
    add_foreign_key "distribution_components", "distributions", :name => "distribution_components_distribution_id_fk"
  end
end
