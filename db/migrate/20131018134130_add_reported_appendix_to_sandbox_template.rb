class AddReportedAppendixToSandboxTemplate < ActiveRecord::Migration
  def change
  	add_column(:trade_sandbox_template, :reported_appendix, :varchar)
  end
end
