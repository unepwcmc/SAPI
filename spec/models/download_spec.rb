# == Schema Information
#
# Table name: downloads
#
#  id           :integer          not null, primary key
#  doc_type     :string(255)
#  format       :string(255)
#  status       :string(255)      default("working")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  path         :string(255)
#  filename     :string(255)
#  display_name :string(255)
#

require 'spec_helper'

describe Download do
  pending "add some examples to (or delete) #{__FILE__}"
end
