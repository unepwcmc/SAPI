# == Schema Information
#
# Table name: taxon_distributions
#
#  id              :integer         not null, primary key
#  taxon_id        :integer         not null
#  distribution_id :integer         not null
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class TaxonDistribution < ActiveRecord::Base
  # attr_accessible :title, :body
end
