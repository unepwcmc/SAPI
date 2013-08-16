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
#

class Quota < TradeRestriction

  attr_accessible :public_display

  validates :quota, :presence => true
  validates :quota, :numericality => { :greater_than_or_equal_to => -1.0 }
  validates :geo_entity_id, :presence => true

  #Each element of CSV columns can be either an array [display_text, method]
  #or a single symbol if the display text and the method are the same
  CSV_COLUMNS = [
    :year, :party, :quota,
    [:unit, :unit_name], :publication_date,
    :notes, :url
  ]

  def start_date_formatted
    start_date ? start_date.strftime('%d/%m/%Y') : Time.now.beginning_of_year.strftime("%d/%m/%Y")
  end

  def end_date_formatted
    end_date ? end_date.strftime('%d/%m/%Y') : Time.now.end_of_year.strftime("%d/%m/%Y")
  end

end
