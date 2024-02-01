class CitesCaptivityProcess < CitesProcess

  STATUS = ['Ongoing', 'Trade Suspension', 'Closed']

  # Change status field to Enum type after upgrading to rails 4.1
  validates :status, presence: true, inclusion: {in: STATUS}
  validates :document_title, presence: true, if: :document?
  validates :document, presence: true, if: :document_title?
  before_validation :set_resolution_value

  private

  def set_resolution_value
    self.resolution = 'Captive Breeding'
  end
end
