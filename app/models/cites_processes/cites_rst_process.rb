# == Schema Information
#
# Table name: cites_processes
#
#  id               :integer          not null, primary key
#  document         :text
#  document_title   :text
#  notes            :text
#  resolution       :string(255)
#  start_date       :datetime
#  status           :string(255)
#  type             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  case_id          :integer
#  created_by_id    :integer
#  geo_entity_id    :integer
#  start_event_id   :integer
#  taxon_concept_id :integer
#  updated_by_id    :integer
#
# Indexes
#
#  index_cites_processes_on_taxon_concept_id  (taxon_concept_id)
#
class CitesRstProcess < CitesProcess

  # Used by lib/modules/import/rst/importer.rb
  # attr_accessible :case_id

  STATUS = ['Initiated', 'Ongoing', 'Retained', 'Trade Suspension', 'Closed']

  # Change status field to Enum type after upgrading to rails 4.1
  validates :status, presence: true, inclusion: {in: STATUS}
  before_validation :set_resolution_value

  private

  def set_resolution_value
    self.resolution = 'Significant Trade'
  end
end
