# == Schema Information
#
# Table name: common_names
#
#  id            :integer          not null, primary key
#  name          :string(255)      not null
#  language_id   :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer
#  updated_by_id :integer
#

class CommonName < ApplicationRecord
  include TrackWhoDoesIt
  # Used by app/models/taxon_common.rb
  # attr_accessible :language_id, :name,
  #   :created_by_id, :updated_by_id

  belongs_to :language
  validates :name, :presence => true,
    :uniqueness => { :scope => :language_id }

  validate :enforce_latin_chars_for_pdf

  def self.english_to_pdf(common_name)
    words = common_name.split
    return common_name if words.size == 1
    words.last + ", " + common_name.chomp(" " + words.last)
  end

  # attribute_accessor to convert postgresql "t" or "f" to a Ruby boolean
  # used in app/serializeres/species/show_taxon_concept_serializer.rb
  # for distinguishing between official CITES languages an non official languages
  # might need to be reviewed: TODO
  def convention_language
    value = self[:convention_language]
    ActiveRecord::Type::Boolean.new.cast(value)
  end

  private

  def enforce_latin_chars_for_pdf
    return unless name.present? && ['EN', 'FR', 'ES'].include?(language.iso_code1)

    errors.add(:name, 'in EN/FR/ES must be PDF-friendly') unless
      name.match? PDF_SAFE_REGEX
  end
end
