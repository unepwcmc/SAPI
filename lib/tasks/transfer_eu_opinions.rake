namespace :eu_opinions do

  desc "transfer the current eu_opinions with iii) eu_decision type to the new SRG referral decision type"
  task :transfer_to_srg_referral_type => :environment do
    old_decision_type_ids = EuDecisionType.where(name: "iii)").pluck(:id)
    fail "Old decision type not found" if old_decision_type_ids.empty?
    eu_opinions = EuOpinion.where(eu_decision_type_id: old_decision_type_ids, is_current: true)
    fail "No eu opinions to transfer" if eu_opinions.count.zero?
    new_decision_type_id = EuDecisionType.find_by_name("SRG Referral").try(:id)
    fail "New decision type not found" if new_decision_type_id.nil?

    puts "There are #{eu_opinions.count} eu_opinions to be transferred"

    query = query_builder(new_decision_type_id, 'eu_decision_type', old_decision_type_ids)
    res = ActiveRecord::Base.connection.execute query

    puts "#{res.cmd_tuples} rows transferred to new decision type"
  end

  desc "transfer the current eu_opinions with ii) eu_decision type to the new SRG History 'In consultation'"
  task :transfer_to_srg_history => :environment do
    old_decision_type_ids = EuDecisionType.where(name: "ii)").pluck(:id)
    fail "Old decision type not found" if old_decision_type_ids.empty?
    eu_opinions = EuOpinion.where(eu_decision_type_id: old_decision_type_ids, is_current: true)
    fail "No eu opinions to transfer" if eu_opinions.count.zero?
    srg_history_id = SrgHistory.find_by_name("In consultation").try(:id)
    fail "New decision type not found" if srg_history_id.nil?

    puts "There are #{eu_opinions.count} eu_opinions to be transferred"

    query = query_builder(srg_history_id, 'srg_history', old_decision_type_ids)
    res = ActiveRecord::Base.connection.execute query

    puts "#{res.cmd_tuples} rows transferred to new decision type"
  end

  def query_builder(new_type, model, old_types)
    set_query =
      if model =~ /history/i
        "SET eu_decision_type_id = NULL, srg_history_id = #{new_type}, updated_at = CURRENT_TIMESTAMP"
      else
        "SET eu_decision_type_id = #{new_type}, updated_at = CURRENT_TIMESTAMP"
      end
    <<-SQL
      WITH current_eu_opinions_with_old_type AS (
        SELECT *
        FROM eu_decisions
        WHERE type = 'EuOpinion'
        AND eu_decision_type_id IN (#{old_types.join(',')})
        AND is_current = true
      )
      UPDATE eu_decisions
      #{set_query}
      FROM current_eu_opinions_with_old_type
      WHERE current_eu_opinions_with_old_type.id = eu_decisions.id
    SQL
  end
end
