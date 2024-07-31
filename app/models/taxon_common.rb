# == Schema Information
#
# Table name: taxon_commons
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer          not null
#  common_name_id   :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  created_by_id    :integer
#  updated_by_id    :integer
#

class TaxonCommon < ApplicationRecord
  include Changeable
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :common_name_id, :taxon_concept_id, :created_by_id,
  #   :updated_by_id, :name, :language_id

  attr_accessor :name, :language_id

  # Rspec file such as `spec/shared/agave.rb`, which assign taxon_concept.common_names = [array of common_name] broken
  # if we remove `optional: true`, although it should be false.
  belongs_to :common_name, optional: true
  belongs_to :taxon_concept, optional: true

  # rspec ./spec/controllers/admin/taxon_commons_controller_spec.rb borken if we remove the following validates.
  validates :common_name_id, presence: true

  before_validation do
    # TaxonCommons can share CommonNames so we don't want to overwrite the
    # common name of another taxon concept.
    #
    # This may mean that we create orphaned CommonName records over time.
    cname = CommonName.find_or_create_by(
      name: name, language_id: language_id
    )

    if cname.valid? && cname.id && common_name_id != cname.id
      self.common_name_id = cname.id
    elsif !cname.valid?
      # Slightly hackily insert the errors - we don't want to fail silently.
      # The message isn't beautiful but it's clear enough and it's only for
      # internal staff.
      #
      # We're not using accept_nested_attributes_for and because of the above
      # logic so we cannot rely on validates_associated.
      errors.add(:base, cname.errors.full_messages&.join(',') || :invalid)
    end
  end
end
