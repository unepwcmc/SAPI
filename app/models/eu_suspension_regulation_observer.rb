class EuSuspensionRegulationObserver < ActiveRecord::Observer

  def before_validation(eu_suspension_regulation)
    eu = Designation.find_by_name('EU')
    eu_suspension_regulation.designation_id = eu && eu.id
  end

  def after_create(eu_suspension_regulation)
    unless eu_suspension_regulation.eu_suspensions_event_id.blank?
      EventEuSuspensionCopyWorker.perform_async(
        eu_suspension_regulation.eu_suspensions_event_id.to_i, eu_suspension_regulation.id
      )
    end
  end

  def after_activate(eu_suspension_regulation)
    EventActivationWorker.perform_async(eu_suspension_regulation.id)
  end

end