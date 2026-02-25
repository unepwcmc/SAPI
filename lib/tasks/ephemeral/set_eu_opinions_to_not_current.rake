namespace :ephemeral do
  ##
  # See ticket cites-support-maintenance 435
  #
  # Following SRG 107, certain opinions on Conolophus subcristatus (4404), which
  # are applied to all countries, have changed as follows:
  #
  # To update: `Negative` opinions for sources W and F to be made not current
  # New opinions: `Negative removed` for sources W and F; mark as not current
  #
  # It does not make sense to make these changes manually.
  task set_eu_opinions_to_not_current: :environment do
    OLD_EVENT_NAME = 'SRG 92'
    NEW_EVENT_NAME = 'SRG 107'
    OLD_DECISION_TYPE = 'Negative'
    NEW_DECISION_TYPE = 'Negative removed'
    SOURCE_CODES = [ 'W', 'F' ]

    ApplicationRecord.transaction do
      new_event = Event.find_by!(name: NEW_EVENT_NAME)
      new_type = EuDecisionType.find_by!(name: NEW_DECISION_TYPE)

      EuDecision.joins(
        :eu_decision_type,
        :start_event,
        :source
      ).where(
        taxon_concept_id: 4404,
        is_current: true,
        eu_decision_type: { name: OLD_DECISION_TYPE },
        start_event: { name: OLD_EVENT_NAME },
        source: { code: SOURCE_CODES }
      ).map do |decision|
        decision.update!(
          is_current: false,
          # Following discussion with SB, end_date is not used.
          # end_date: new_event.effective_at,
          end_event: new_event
        )

        replacement_decision = decision.dup

        replacement_decision.is_current = false
        replacement_decision.eu_decision_type = new_type
        replacement_decision.start_event = new_event
        replacement_decision.start_date = new_event.effective_at # todo - confirm
        replacement_decision.note = 'All countries' # todo - specify

        replacement_decision.save!

        replacement_decision
      end

      raise 'Dry run: Rollback'
    end
  end
end
