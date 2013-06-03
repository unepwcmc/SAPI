# == Schema Information
#
# Table name: trade_restrictions
#
#  id                          :integer          not null, primary key
#  is_current                  :boolean
#  start_date                  :datetime
#  end_date                    :datetime
#  geo_entity_id               :integer
#  quota                       :float
#  publication_date            :datetime
#  notes                       :text
#  type                        :string(255)
#  unit_id                     :integer
#  taxon_concept_id            :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  public_display              :boolean          default(TRUE)
#  url                         :text
#  start_notification_id       :integer
#  end_notification_id         :integer
#  excluded_taxon_concepts_ids :string
#

class CitesSuspension < TradeRestriction
  attr_accessible :start_notification_id, :end_notification_id
  belongs_to :taxon_concept
  belongs_to :start_notification, :class_name => 'CitesSuspensionNotification'
  belongs_to :end_notification, :class_name => 'CitesSuspensionNotification'
  before_validation :handle_dates
  validates :start_notification_id, :presence => true

  def handle_dates
    self.publication_date = start_notification && start_notification.effective_at
    self.start_date = start_notification && start_notification.effective_at
    self.end_date = end_notification && end_notification.effective_at
  end

  CSV_COLUMNS = [
    :id, :start_date, :party, :quota,
    :unit_name, :publication_date,
    :notes, :url, :public_display
  ]
end
