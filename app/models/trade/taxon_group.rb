# == Schema Information
#
# Table name: trade_taxon_groups
#
#  id         :bigint           not null, primary key
#  code       :string
#  name_en    :string
#  name_es    :string
#  name_fr    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_trade_taxon_groups_on_code  (code) UNIQUE
#
class Trade::TaxonGroup < ApplicationRecord
  # Populated exclusively by the application via a rake task
end
