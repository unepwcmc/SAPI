# == Schema Information
#
# Table name: cms_mappings
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer
#  cms_uuid         :string(255)
#  cms_taxon_name   :string(255)
#  cms_author       :string(255)
#  details          :hstore
#  accepted_name_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe CmsMapping do
  pending "add some examples to (or delete) #{__FILE__}"
end
