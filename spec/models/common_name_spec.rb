# == Schema Information
#
# Table name: common_names
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  reference_id :integer
#  language_id  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe CommonName do
  pending "add some examples to (or delete) #{__FILE__}"
end
