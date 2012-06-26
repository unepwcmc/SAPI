# == Schema Information
#
# Table name: taxon_commons
#
#  id               :integer         not null, primary key
#  taxon_concept_id :integer
#  common_name_id   :integer
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

require 'spec_helper'

describe TaxonCommon do
  pending "add some examples to (or delete) #{__FILE__}"
end
