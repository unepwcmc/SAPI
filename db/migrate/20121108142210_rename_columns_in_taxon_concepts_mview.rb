class RenameColumnsInTaxonConceptsMview < ActiveRecord::Migration
  def up
    execute "ALTER TABLE taxon_concepts_mview RENAME fully_covered TO cites_fully_covered"
    execute "ALTER TABLE taxon_concepts_mview RENAME usr_cites_exclusion TO usr_cites_excluded"
    execute "ALTER TABLE taxon_concepts_mview RENAME cites_exclusion TO cites_excluded"
    execute "ALTER TABLE taxon_concepts_mview RENAME cites_del TO cites_deleted"
  end

  def down
    execute "ALTER TABLE taxon_concepts_mview RENAME cites_fully_covered TO fully_covered"
    execute "ALTER TABLE taxon_concepts_mview RENAME usr_cites_excluded TO usr_cites_exclusion"
    execute "ALTER TABLE taxon_concepts_mview RENAME cites_excluded TO cites_exclusion"
    execute "ALTER TABLE taxon_concepts_mview RENAME cites_deleted TO cites_del"
  end
end
