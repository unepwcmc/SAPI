class RenameSynonymIdToAcceptedNameIdInIucnMappings < ActiveRecord::Migration
  def change
    rename_column :iucn_mappings, :synonym_id, :accepted_name_id
  end
end
