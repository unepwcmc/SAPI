class EuEventObserver < ActiveRecord::Observer
  observe :eu_regulation, :eu_suspension_regulation,
    :eu_implementing_regulation, :eu_council_regulation

  def before_validation(eu_event)
    eu = Designation.find_by_name('EU')
    eu_event.designation_id = eu && eu.id
  end

end
