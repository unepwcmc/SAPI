class NewJsonObjectColumnsForPaperTrail < ActiveRecord::Migration[7.0]
  def up
    safety_assured {
      rename_column :taxon_concept_versions, :object, :object_yml
      rename_column :versions, :object, :object_yml
      rename_column :versions, :object_changes, :object_changes_yml

      add_column :taxon_concept_versions, :object, :jsonb, default: {}
      add_column :versions, :object, :jsonb, default: {}
      add_column :versions, :object_changes, :jsonb, default: {}
    }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
