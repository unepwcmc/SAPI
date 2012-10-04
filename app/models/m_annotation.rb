# == Schema Information
#
# Table name: listing_changes_mview
#
#  id                   :integer
#  taxon_concept_id     :integer
#  effective_at         :datetime
#  species_listing_id   :integer
#  species_listing_name :string(255)
#  change_type_id       :integer
#  change_type_name     :string(255)
#  party_id             :integer
#  party_name           :string(255)
#  dirty                :boolean
#  expiry               :datetime
#

class MAnnotation < ActiveRecord::Base
  self.table_name = :annotations_mview
  self.primary_key = :id
  has_many :m_annotations, :foreign_key => :listing_change_id
end
