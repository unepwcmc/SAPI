class RenameSynonymIdToAcceptedNameIdInIucnMappings < ActiveRecord::Migration[4.2]
  def change
    rename_column :iucn_mappings, :synonym_id, :accepted_name_id
  end
end
