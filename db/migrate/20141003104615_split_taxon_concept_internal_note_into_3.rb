class SplitTaxonConceptInternalNoteInto3 < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :internal_distribution_note, :text
    rename_column :taxon_concepts, :internal_notes, :internal_general_note
    # check if the internal nomenclature note exists already
    res = ActiveRecord::Base.connection.execute(
      "SELECT column_name FROM information_schema.columns
      WHERE table_name='taxon_concepts' and column_name='internal_nomenclature_note'"
    )
    unless res.ntuples > 0
      add_column :taxon_concepts, :internal_nomenclature_note, :text
    end
  end
end
