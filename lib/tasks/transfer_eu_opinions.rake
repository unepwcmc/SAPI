namespace :eu_opinions do

  desc "transfer the current eu_opinions with iii) and iii)removed eu_decision type to the new SRG referral decision type"
  task :tranfer_to_srg_referral_type => :environment do
    old_decision_type_ids = EuDecisionType.where(name: ["iii)", "iii) removed"]).pluck(:id)
    eu_opinions = EuOpinion.where(eu_decision_type_id: old_decision_type_ids, is_current: true)
    new_decision_type_id = EuDecisionType.find_by_name("SRG Referral").id
    puts "There are #{eu_opinions.count} eu_opinions to be transferred"
    update_query = <<-SQL
      WITH current_eu_opinions_with_iii_type AS (
        SELECT *
        FROM eu_decisions
        WHERE type = 'EuOpinion'
        AND eu_decision_type_id IN (#{old_decision_type_ids.join(',')})
        AND is_current = true
      )
      UPDATE eu_decisions
      SET eu_decision_type_id = #{new_decision_type_id}
      FROM current_eu_opinions_with_iii_type
      WHERE current_eu_opinions_with_iii_type.id = eu_decisions.id
    SQL
    res = ActiveRecord::Base.connection.execute update_query
    puts "#{res.cmd_tuples} rows transferred to SRG Referral decision type"
  end

  desc "transfer the current eu_opinions with ii) and ii)removed eu_decision type to the new SRG History 'In consultation'"
  task :transfer_to_srg_history => :environment do
    old_decision_type_ids = EuDecisionType.where(name: ["ii)", "ii) removed"]).pluck(:id)
    eu_opinions = EuOpinion.where(eu_decision_type_id: old_decision_type_ids, is_current: true)
    srg_history_id = SrgHistory.find_by_name("In consultation").id
    puts "There are #{eu_opinions.count} eu_opinions to be transferred"
    update_query = <<-SQL
      WITH current_eu_opinions_with_ii_type AS (
        SELECT *
        FROM eu_decisions
        WHERE type = 'EuOpinion'
        AND eu_decision_type_id IN (#{old_decision_type_ids.join(',')})
        AND is_current = true
      )
      UPDATE eu_decisions
      SET eu_decision_type_id = NULL, srg_history_id = #{srg_history_id}
      FROM current_eu_opinions_with_ii_type
      WHERE current_eu_opinions_with_ii_type.id = eu_decisions.id
    SQL
    res = ActiveRecord::Base.connection.execute update_query
    puts "#{res.cmd_tuples} rows transferred to SRG History"
  end
end
