# == Schema Information
#
# Table name: distribution_references
#
#  id              :integer          not null, primary key
#  distribution_id :integer          not null
#  reference_id    :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  updated_by_id   :integer
#  created_by_id   :integer
#

class DistributionReference < ApplicationRecord
  include TrackWhoDoesIt
  # Used by app/models/cms_mapping_manager.rb
  # attr_accessible :reference_id, :distribution_id, :created_by_id,
  #   :updated_by_id

  belongs_to :reference
  belongs_to :distribution, :touch => true

  validates :distribution_id, :uniqueness => { :scope => :reference_id }
end
