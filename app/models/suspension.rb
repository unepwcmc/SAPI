# == Schema Information
#
# Table name: trade_restrictions
#
#  id               :integer          not null, primary key
#  is_current       :boolean
#  start_date       :datetime
#  end_date         :datetime
#  geo_entity_id    :integer
#  quota            :float
#  publication_date :datetime
#  notes            :text
#  suspension_basis :string(255)
#  type             :string(255)
#  unit_id          :integer
#  taxon_concept_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  public_display   :boolean          default(TRUE)
#  url              :text
#  import_row_id    :integer
#

class Suspension < TradeRestriction
  belongs_to :taxon_concept

  CSV_COLUMNS = [
    :id, :start_date, :party, :quota,
    :unit_name, :publication_date,
    :notes, :url, :public_display
  ]
end
