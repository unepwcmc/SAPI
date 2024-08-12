# == Schema Information
#
# Table name: events
#
#  id                   :integer          not null, primary key
#  description          :text
#  effective_at         :datetime
#  end_date             :datetime
#  extended_description :text
#  is_current           :boolean          default(FALSE), not null
#  multilingual_url     :text
#  name                 :string(255)
#  private_url          :text
#  published_at         :datetime
#  subtype              :string(255)
#  type                 :string(255)      default("Event"), not null
#  url                  :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  designation_id       :integer
#  elib_legacy_id       :integer
#  legacy_id            :integer
#  updated_by_id        :integer
#
# Foreign Keys
#
#  events_created_by_id_fk   (created_by_id => users.id)
#  events_designation_id_fk  (designation_id => designations.id)
#  events_updated_by_id_fk   (updated_by_id => users.id)
#

class Event < ApplicationRecord
  include TrackWhoDoesIt

  # Migrated to controller (Strong Parameters)
  # attr_accessible :name, :designation_id, :description, :extended_description,
  #   :url, :private_url, :multilingual_url, :published_at, :effective_at, :is_current, :end_date,
  #   :created_by_id, :updated_by_id

  attr_reader :effective_at_formatted

  belongs_to :designation, optional: true
  has_many :annotations, dependent: :destroy
  has_many :documents
  has_many :cites_processes

  validates :name, presence: true, uniqueness: true
  validates :url, format: URI::regexp(%w(http https)), allow_blank: true

  def self.elibrary_current_event_types
    [CitesCop, CitesAc, CitesPc, EcSrg]
  end

  # Returns event types (class objects) that are relevant to E-Library
  def self.elibrary_event_types
    elibrary_current_event_types + [CitesTc, CitesExtraordinaryMeeting]
  end

  def self.event_types_with_names
    [
      {
        id: 'CitesCop',
        name: 'CITES CoP'
      },
      {
        id: 'CitesAc',
        name: 'CITES Animals Committee'
      },
      {
        id: 'CitesPc',
        name: 'CITES Plants Committee'
      },
      {
        id: 'EcSrg',
        name: 'EU Scientific Review Group'
      },
      {
        id: 'CitesTc',
        name: 'CITES Technical Committee'
      },
      {
        id: 'IdMaterials',
        name: 'IdentificationMaterials'
      }
    ]
  end

  # Returns document types (class objects) that are relevant to E-Library and
  # that can be associated with this event type
  # Should be overriden in subclasses
  def self.elibrary_document_types
    [Document]
  end

  def effective_at_formatted
    effective_at && effective_at.strftime('%d/%m/%Y')
  end

  def published_at_formatted
    published_at && published_at.strftime('%d/%m/%Y')
  end

  def end_date_formatted
    end_date && end_date.strftime('%d/%m/%Y')
  end

  def self.search(query)
    if query.present?
      where("UPPER(events.name) LIKE UPPER(:query)
            OR UPPER(events.description) LIKE UPPER(:query)",
            query: "%#{query}%")
    else
      all
    end
  end

  def activate!
    update(is_current: true)
  end

  def deactivate!
    update(is_current: false)
  end

  protected

  def designation_is_cites
    cites = Designation.find_by_name('CITES')
    unless designation_id && cites && designation_id == cites.id
      errors.add(:designation_id, 'should be CITES')
    end
  end

  def designation_is_eu
    eu = Designation.find_by_name('EU')
    unless designation_id && eu && designation_id == eu.id
      errors.add(:designation_id, 'should be EU')
    end
  end
end
