class CreateCmsMappings < ActiveRecord::Migration
  def change
    create_table :cms_mappings do |t|
      t.integer :taxon_concept_id
      t.string :cms_uuid
      t.string :cms_taxon_name
      t.string :cms_author
      t.hstore :details
      t.integer :accepted_name_id

      t.timestamps
    end
  end
end
