# == Schema Information
#
# Table name: trade_restriction_terms
#
#  id                   :integer          not null, primary key
#  trade_restriction_id :integer
#  term_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'spec_helper'

describe TradeRestrictionTerm do
  pending "add some examples to (or delete) #{__FILE__}"
end
