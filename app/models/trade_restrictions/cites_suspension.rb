# == Schema Information
#
# Table name: trade_restrictions
#
#  id                          :integer          not null, primary key
#  applies_to_import           :boolean          default(FALSE), not null
#  end_date                    :datetime
#  excluded_taxon_concepts_ids :integer          is an Array
#  internal_notes              :text
#  is_current                  :boolean          default(TRUE)
#  nomenclature_note_en        :text
#  nomenclature_note_es        :text
#  nomenclature_note_fr        :text
#  notes                       :text
#  public_display              :boolean          default(TRUE)
#  publication_date            :datetime
#  quota                       :float
#  start_date                  :datetime
#  type                        :string(255)
#  url                         :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  created_by_id               :integer
#  end_notification_id         :integer
#  geo_entity_id               :integer
#  original_id                 :integer
#  start_notification_id       :integer
#  taxon_concept_id            :integer
#  unit_id                     :integer
#  updated_by_id               :integer
#
# Indexes
#
#  idx_on_is_current_type_taxon_concept_id_a115d056cb  (is_current,type,taxon_concept_id)
#  index_trade_restrictions_on_created_by_id           (created_by_id)
#  index_trade_restrictions_on_end_notification_id     (end_notification_id)
#  index_trade_restrictions_on_geo_entity_id           (geo_entity_id)
#  index_trade_restrictions_on_start_notification_id   (start_notification_id)
#  index_trade_restrictions_on_taxon_concept_id        (taxon_concept_id)
#  index_trade_restrictions_on_unit_id                 (unit_id)
#  index_trade_restrictions_on_updated_by_id           (updated_by_id)
#  trade_restrictions_extract_year_from_start_date     (date_part('year'::text, start_date)) WHERE ((type)::text = 'Quota'::text)
#
# Foreign Keys
#
#  trade_restrictions_created_by_id_fk          (created_by_id => users.id)
#  trade_restrictions_end_notification_id_fk    (end_notification_id => events.id)
#  trade_restrictions_geo_entity_id_fk          (geo_entity_id => geo_entities.id)
#  trade_restrictions_start_notification_id_fk  (start_notification_id => events.id)
#  trade_restrictions_taxon_concept_id_fk       (taxon_concept_id => taxon_concepts.id)
#  trade_restrictions_unit_id_fk                (unit_id => trade_codes.id)
#  trade_restrictions_updated_by_id_fk          (updated_by_id => users.id)
#

class CitesSuspension < TradeRestriction
  include Changeable
  # Migrated to controller (Strong Parameters)
  # attr_accessible :start_notification_id, :end_notification_id,
  #   :cites_suspension_confirmations_attributes,
  #   :applies_to_import
  belongs_to :taxon_concept, optional: true
  belongs_to :start_notification, class_name: 'CitesSuspensionNotification'
  belongs_to :end_notification, class_name: 'CitesSuspensionNotification', optional: true
  has_many :cites_suspension_confirmations, dependent: :destroy
  has_many :confirmation_notifications, through: :cites_suspension_confirmations
  before_validation :handle_dates
  before_save :handle_current_flag
  accepts_nested_attributes_for :cites_suspension_confirmations
  after_commit :async_downloads_cache_cleanup, on: :destroy

  def handle_dates
    self.publication_date = start_notification && start_notification.effective_at
    self.start_date = start_notification && start_notification.effective_at
    self.end_date = end_notification && end_notification.effective_at
  end

  def handle_current_flag
    self.is_current = end_notification_id.blank?
    true
  end

  # Each element of CSV columns can be either an array [display_text, method]
  # or a single symbol if the display text and the method are the same
  CSV_COLUMNS = [
    [ :start_date, :start_date_formatted ], [ :start_notification, :start_notification_name ],
    [ :end_date, :end_date_formatted ], [ :end_notification, :end_notification_name ],
    :party, :notes, [ :valid, :is_current ]
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

private

  def async_downloads_cache_cleanup
    DownloadsCacheCleanupWorker.perform_async('cites_suspensions')
  end
end
