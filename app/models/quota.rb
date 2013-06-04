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
#  suspension_basis            :string(255)
#  type                        :string(255)
#  unit_id                     :integer
#  taxon_concept_id            :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  public_display              :boolean          default(TRUE)
#  url                         :text
#  import_row_id               :integer
#  start_notification_id       :integer
#  end_notification_id         :integer
#  excluded_taxon_concepts_ids :string
#

class Quota < TradeRestriction

  validates :quota, :presence => true
  validates :quota, :numericality => { :only_integer => true, :greater_than => 0 }

  validates :unit, :presence => true

  CSV_COLUMNS = [
    :id, :year, :party, :quota,
    :unit_name, :publication_date,
    :notes, :url, :public_display
  ]

  def party
    geo_entity_id ? geo_entity.name_en : ''
  end

  def unit_name
    unit_id ? unit.name_en : ''
  end
end
