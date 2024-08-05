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
    safety_assured {
      execute %Q{
        UPDATE taxon_concept_versions SET object_yml = '---' || chr(10) || object::JSON::TEXT || chr(10) WHERE object IS NOT NULL AND object_yml IS NULL
        UPDATE versions SET object_yml = '---' || chr(10) || object::JSON::TEXT || chr(10) WHERE object IS NOT NULL AND object_yml IS NULL
        UPDATE versions SET object_changes_yml = '---' || chr(10) || object_changes::JSON::TEXT || chr(10) WHERE object_changes IS NOT NULL AND object_changes_yml IS NULL
      }

      drop_column :taxon_concept_versions, :object
      drop_column :versions, :object
      drop_column :versions, :object_changes

      rename_column :taxon_concept_versions, :object_yml, :object
      rename_column :versions, :object_yml, :object
      rename_column :versions, :object_changes_yml, :object_changes
    }
  end
end
