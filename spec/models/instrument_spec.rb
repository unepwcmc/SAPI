# == Schema Information
#
# Table name: instruments
#
#  id             :integer          not null, primary key
#  designation_id :integer
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe Instrument do
  pending "add some examples to (or delete) #{__FILE__}"
end
