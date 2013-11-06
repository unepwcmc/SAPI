class AddReportedSpeciesNameToSandboxTemplate < ActiveRecord::Migration
  def change
    add_column(:trade_sandbox_template, :reported_species_name, :varchar)
  end
end
