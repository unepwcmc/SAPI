# == Schema Information
#
# Table name: distribution_references
#
#  id              :integer          not null, primary key
#  distribution_id :integer          not null
#  reference_id    :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#

class DistributionReference < ActiveRecord::Base
  attr_accessible :reference_id, :distribution_id

  belongs_to :reference
  belongs_to :distribution, :touch => true
end
