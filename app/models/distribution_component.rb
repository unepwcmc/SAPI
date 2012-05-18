# == Schema Information
#
# Table name: distribution_components
#
#  id              :integer         not null, primary key
#  distribution_id :integer         not null
#  component_id    :integer         not null
#  component_type  :string(255)     not null
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class DistributionComponent < ActiveRecord::Base
  belongs_to :component, :polymorphic => true
end
