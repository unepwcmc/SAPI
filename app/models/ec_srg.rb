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
#

# European Commission Scientific Review Group

class EcSrg < Event
  attr_accessible :is_current

  validates :effective_at, :presence => true

  def self.elibrary_document_types
    [
      Document::MeetingAgenda,
      Document::ShortSummaryOfConclusions,
      Document::AgendaItems,
      Document::DetailedSummaryOfConclusions,
      Document::RangeStateConsultationLetter,
      Document::ListOfParticipants
    ]
  end

end
