class AddFullNameToTaxonConcepts < ActiveRecord::Migration
  def up
    add_column :taxon_concepts, :full_name, :string
    execute "UPDATE taxon_concepts SET full_name = data->'full_name'"
    execute "UPDATE taxon_concepts SET data = data - ARRAY['full_name']"
  end

  def down
    execute "UPDATE taxon_concepts SET data = data || hstore('full_name', full_name)"
    remove_column :taxon_concepts, :full_name
  end
end
