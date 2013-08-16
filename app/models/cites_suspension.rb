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
  attr_accessible :start_notification_id, :end_notification_id,
    :cites_suspension_confirmations_attributes
  belongs_to :taxon_concept
  belongs_to :start_notification, :class_name => 'CitesSuspensionNotification'
  belongs_to :end_notification, :class_name => 'CitesSuspensionNotification'
  has_many :cites_suspension_confirmations, :dependent => :destroy
  has_many :confirmation_notifications, :through => :cites_suspension_confirmations
  before_validation :handle_dates
  before_save :handle_current_flag
  validates :start_notification_id, :presence => true
  accepts_nested_attributes_for :cites_suspension_confirmations

  def handle_dates
    self.publication_date = start_notification && start_notification.effective_at
    self.start_date = start_notification && start_notification.effective_at
    self.end_date = end_notification && end_notification.effective_at
  end

  def handle_current_flag
    self.is_current = !end_notification_id.present?
    true
  end

  #Each element of CSV columns can be either an array [display_text, method]
  #or a single symbol if the display text and the method are the same
  CSV_COLUMNS = [
    [:start_date, :start_date_formatted], [:start_notification, :start_notification_name],
    [:end_date, :end_date_formatted], [:end_notification, :end_notification_name],
    :party, :notes, [:valid, :is_current]
  ]

  def start_notification_name
    start_notification && start_notification.name
  end
  def end_notification_name
    end_notification && end_notification.name
  end

  def start_date_formatted
    start_date ? start_date.strftime('%d/%m/%Y') : ''
  end

  def end_date_formatted
    end_date ? end_date.strftime('%d/%m/%Y') : ''
  end
end
