namespace :ephemeral do
  ##
  # See ticket cites-support-maintenance 435
  # https://unep-wcmc.codebasehq.com/projects/cites-support-maintenance/tickets/435
  #
  # Run in dry-run mode by default:
  #   bundle exec rake ephemeral:set_eu_opinions_to_not_current
  # Persist changes explicitly:
  #   DRY_RUN=false bundle exec rake ephemeral:set_eu_opinions_to_not_current
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
    # Default to a dry run so this one-off data fix can be verified safely
    # before it is allowed to persist changes in production-like environments.
    DRY_RUN = ENV.fetch('DRY_RUN', 'true')
    dry_run = ActiveModel::Type::Boolean.new.cast(DRY_RUN)

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

        # The start date and the date in the note are in fact different for
        # SRG 107 decisions, and this is intentional, per ticker 435.
        replacement_decision.start_date = new_event.effective_at
        replacement_decision.notes =
          'The decision came into effect when the Annex A listing for the species came into force on 29/06/2026'

        replacement_decision.save!

        replacement_decision
      end

      # Use an explicit rollback instead of a generic error so the task keeps the
      # transaction behavior intentional and predictable for dry-run verification.
      raise ActiveRecord::Rollback, 'Dry run: rollback' if dry_run
    end
  end
end
