class RenameSuspensionsToCitesSuspensions < ActiveRecord::Migration
  def up
    TradeRestriction.update_all({:type => 'CitesSuspension'}, {:type => 'Suspension'})
  end

  def down
    TradeRestriction.update_all({:type => 'Suspension'}, {:type => 'CitesSuspension'})
  end
end
