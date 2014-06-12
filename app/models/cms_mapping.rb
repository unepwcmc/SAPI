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

class CmsMapping < ActiveRecord::Base
  attr_accessible :accepted_name_id, :cms_author, :cms_taxon_name, :cms_uuid, :details, :taxon_concept_id
end
