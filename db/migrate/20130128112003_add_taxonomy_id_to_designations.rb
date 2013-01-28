class AddTaxonomyIdToDesignations < ActiveRecord::Migration
  def change
    taxonomy = Taxonomy.find_or_create_by_name(Taxonomy::WILDLIFE_TRADE)
    add_column :designations, :taxonomy_id, :integer
    execute <<-SQL
      UPDATE designations SET taxonomy_id = CASE
        WHEN name = 'CITES' THEN 'WILDLIFE_TRADE'
        ELSE 'CMS'
      END
    SQL
    change_table :designations do |t|
      t.change :taxonomy_id, :integer, :null => false, :default => taxonomy.id
      t.foreign_key :taxonomies, :name => "designations_taxonomy_id_fk"
    end
  end
end
