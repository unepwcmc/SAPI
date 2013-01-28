class AddTaxonomyIdToDesignations < ActiveRecord::Migration
  def up
    taxonomy = Taxonomy.find_or_create_by_name(Taxonomy::WILDLIFE_TRADE)
    change_table :designations do |t|
      t.column :taxonomy_id, :integer, :null => false, :default => taxonomy.id
      t.foreign_key :taxonomies, :name => "designations_taxonomy_id_fk"
    end
  end
  def down
    change_table :designations do |t|
      t.remove_foreign_key :taxonomies
      t.remove :taxonomy_id
    end
  end
end
