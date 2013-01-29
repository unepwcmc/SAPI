class AddTaxonomyIdToDesignations < ActiveRecord::Migration
  def change
    cites_eu = Taxonomy.find_or_create_by_name(Taxonomy::CITES_EU)
    cms = Taxonomy.find_or_create_by_name(Taxonomy::CMS)
    add_column :designations, :taxonomy_id, :integer
    execute <<-SQL
      UPDATE designations SET taxonomy_id = CASE
        WHEN name = 'CITES' THEN #{cites_eu.id}
        ELSE #{cms.id}
      END
    SQL
    change_table :designations do |t|
      t.change :taxonomy_id, :integer, :null => false, :default => cites_eu.id
      t.foreign_key :taxonomies, :name => "designations_taxonomy_id_fk"
    end
  end
end
