# == Schema Information
#
# Table name: events
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  designation_id       :integer
#  description          :text
#  url                  :text
#  is_current           :boolean          default(FALSE), not null
#  type                 :string(255)      default("Event"), not null
#  effective_at         :datetime
#  published_at         :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  legacy_id            :integer
#  end_date             :datetime
#  subtype              :string(255)
#  updated_by_id        :integer
#  created_by_id        :integer
#  extended_description :text
#  multilingual_url     :text
#  elib_legacy_id       :integer
#

# Cites Tech Committee

class CitesTc < Event
  attr_accessible :is_current

  validates :effective_at, :presence => true

  before_destroy :check_for_documents

  def self.elibrary_document_types
    [Document::ReviewOfSignificantTrade]
  end

  private

  def check_for_documents
    if documents.present?
      errors.add(:base, "failed. Please delete the associated documents before destroying this event.")
      return false
    end
  end

end
