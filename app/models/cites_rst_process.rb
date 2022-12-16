class CitesRstProcess < CitesProcess

  attr_accessible :case_id

  STATUS = ['Initiated', 'Ongoing', 'Retained', 'Trade Suspension', 'Closed']

  # Change status field to Enum type after upgrading to rails 4.1
  validates :status, presence: true, inclusion: {in: STATUS}
  before_validation :set_resolution_value

  private

  def set_resolution_value
    self.resolution = 'Significant Trade'
  end
end
