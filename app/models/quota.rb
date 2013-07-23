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

class Quota < TradeRestriction

  validates :quota, :presence => true
  validates :quota, :numericality => { :only_integer => true, :greater_than => 0 }

  validates :unit, :presence => true

  #Each element of CSV columns can be either an array [display_text, method]
  #or a single symbol if the display text and the method are the same
  CSV_COLUMNS = [
    :year, :party, :quota,
    [:unit, :unit_name], :publication_date,
    :notes, :url
  ]

  def start_date_formatted
    start_date ? start_date.strftime('%d/%m/%y') : Time.now.beginning_of_year.strftime("%d/%m/%y")
  end

  def end_date_formatted
    end_date ? end_date.strftime('%d/%m/%y') : Time.now.end_of_year.strftime("%d/%m/%y")
  end

end
