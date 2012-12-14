# == Schema Information
#
# Table name: trade_codes
#
#  id             :integer          not null, primary key
#  code           :string(255)      not null
#  name_en        :string(255)      not null
#  description_en :string(255)
#  type           :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  name_es        :string(255)
#  name_fr        :string(255)
#  description_es :string(255)
#  description_fr :string(255)
#

class Term < TradeCode; end
