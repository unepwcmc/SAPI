# == Schema Information
#
# Table name: admin_iucn_mappings
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer
#  iucn_taxon_id    :integer
#  iucn_taxon_name  :string(255)
#  iucn_author      :string(255)
#  iucn_category    :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  details          :hstore
#  synonym_id       :integer
#

require 'spec_helper'

describe Admin::IucnMapping do
  pending "add some examples to (or delete) #{__FILE__}"
end
