class AddTaxonConceptIdToSandbox < ActiveRecord::Migration
  def change
    add_column(:trade_sandbox_template, :reported_taxon_concept_id, :integer)
    add_column(:trade_sandbox_template, :taxon_concept_id, :integer)
  end
end
