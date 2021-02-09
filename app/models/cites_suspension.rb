# == Schema Information
#
# Table name: trade_restrictions
#
#  id                          :integer          not null, primary key
#  is_current                  :boolean          default(TRUE)
#  start_date                  :datetime
#  end_date                    :datetime
#  geo_entity_id               :integer
#  quota                       :float
#  publication_date            :datetime
#  notes                       :text
#  type                        :string(255)
#  unit_id                     :integer
#  taxon_concept_id            :integer
#  public_display              :boolean          default(TRUE)
#  url                         :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  start_notification_id       :integer
#  end_notification_id         :integer
#  excluded_taxon_concepts_ids :string
#  original_id                 :integer
#  updated_by_id               :integer
#  created_by_id               :integer
#  internal_notes              :text
#  nomenclature_note_en        :text
#  nomenclature_note_es        :text
#  nomenclature_note_fr        :text
#  applies_to_import           :boolean          default(FALSE), not null
#

class CitesSuspension < TradeRestriction
  attr_accessible :start_notification_id, :end_notification_id,
    :cites_suspension_confirmations_attributes,
    :applies_to_import
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

  # Each element of CSV columns can be either an array [display_text, method]
  # or a single symbol if the display text and the method are the same
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

  def self.search(query)
    if query.present?
      where("UPPER(geo_entities.name_en) LIKE UPPER(:query)
            OR UPPER(geo_entities.iso_code2) LIKE UPPER(:query)
            OR trade_restrictions.start_date::text LIKE :query
            OR trade_restrictions.end_date::text LIKE :query
            OR UPPER(trade_restrictions.notes) LIKE UPPER(:query)
            OR UPPER(taxon_concepts.full_name) LIKE UPPER(:query)
            OR UPPER(events.subtype) LIKE UPPER(:query)",
            :query => "%#{query}%").
      joins([:start_notification]).
      joins(<<-SQL
          LEFT JOIN taxon_concepts
            ON taxon_concepts.id = trade_restrictions.taxon_concept_id
          LEFT JOIN geo_entities
            ON geo_entities.id = trade_restrictions.geo_entity_id
        SQL
      )
    else
      all
    end
  end
end
