class AddNameStatusToTaxonConcepts < ActiveRecord::Migration
  def up
    add_column :taxon_concepts, :name_status, :string, :null => false, :default => 'A'
    execute "UPDATE taxon_concepts SET name_status = CASE WHEN (data->'cites_name_status')::VARCHAR  IS NULL THEN 'A' ELSE data->'cites_name_status' END"
    execute "UPDATE taxon_concepts SET data = data - ARRAY['cites_name_status']"
  end

  def down
    execute "UPDATE taxon_concepts SET data = data || hstore('cites_name_status', name_status)"
    remove_column :taxon_concepts, :name_status
  end
end
