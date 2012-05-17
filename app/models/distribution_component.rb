class DistributionComponent < ActiveRecord::Base
  belongs_to :component, :polymorphic => true
end
