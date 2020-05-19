namespace :eu_opinions do
  # Usage:
  # bundle exec rake eu_opinions:transfer_current_eu_opinions_decision_type['eu_decision_type','SRG Referral','iii)']
  # bundle exec rake eu_opinions:transfer_current_eu_opinions_decision_type['srg_history','In consultation','ii)']
  desc "transfer current eu opinions to new decision type/Srg History"
  task :transfer_current_eu_opinions_decision_type, [:model, :new_type, :old_type] => [:environment] do |t, args|

    old_decision_type_ids = EuDecisionType.where('name ILIKE ?', "#{args[:old_type]}%").pluck(:id)
    fail "Decision type #{args[:old_type]} not found" if old_decision_type_ids.empty?
    eu_opinions = EuOpinion.where(eu_decision_type_id: old_decision_type_ids, is_current: true)
    fail "No eu opinions to transfer" if eu_opinions.count.zero?
    new_decision_type_id = args[:model].camelize.constantize.find_by_name(args[:new_type]).try(:id)
    fail "Decision type #{args[:new_type]} not found" if new_decision_type_id.nil?

    puts "There are #{eu_opinions.count} eu_opinions to be transferred"

    query = query_builder(new_decision_type_id, args[:model], old_decision_type_ids)
    res = ActiveRecord::Base.connection.execute query

    puts "#{res.cmd_tuples} rows transferred to new decision type"
  end

  def query_builder(new_type, model, old_types)
    set_query =
      if model =~ /history/i
        "SET eu_decision_type_id = NULL, srg_history_id = #{new_type}"
      else
        "SET eu_decision_type_id = #{new_type}"
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
