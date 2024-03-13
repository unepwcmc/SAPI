class EuEvent < Event
  before_validation do
    eu = Designation.find_by_name('EU')
    self.designation_id = eu && eu.id
  end
end
