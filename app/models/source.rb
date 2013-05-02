# == Schema Information
#
# Table name: trade_codes
#
#  id         :integer          not null, primary key
#  code       :string(255)      not null
#  name_en    :string(255)      not null
#  type       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name_es    :string(255)
#  name_fr    :string(255)
#

class Source < TradeCode
  validates :code, :length => {:is => 1}
  def can_be_deleted?
    EuDecision.where(:source_id => self.id).length == 0 &&
    TradeRestrictionSource.where(:source_id => self.id).length == 0
  end
end
