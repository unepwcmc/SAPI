# == Schema Information
#
# Table name: standard_references
#
#  id                  :integer          not null, primary key
#  author              :string(255)
#  title               :text
#  year                :integer
#  reference_id        :integer
#  reference_legacy_id :integer
#  taxon_concept_name  :string(255)
#  taxon_concept_rank  :string(255)
#  taxon_concept_id    :integer
#  species_legacy_id   :integer
#  position            :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class StandardReference < ActiveRecord::Base
  attr_accessible :author, :reference_id, :reference_legacy_id,
  :species_legacy_id, :taxon_concept_id, :taxon_concept_name,
  :taxon_concept_rank, :title, :year
end
