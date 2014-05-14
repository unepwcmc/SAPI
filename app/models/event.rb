# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  designation_id :integer
#  effective_at   :datetime
#  published_at   :datetime
#  description    :text
#  url            :text
#  is_current     :boolean          default(FALSE), not null
#  type           :string(255)      default("Event"), not null
#  legacy_id      :integer
#  end_date       :datetime
#  subtype        :string(255)
#  updated_by_id :interger
#  created_by_id :interger
#

class Event < ActiveRecord::Base
  track_who_does_it
  attr_accessible :name, :designation_id, :description, :url, :effective_at, :is_current
  attr_reader :effective_at_formatted

  belongs_to :designation
  has_many :annotations, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => true
  validates :url, :format => URI::regexp(%w(http https)), :allow_blank => true

  def effective_at_formatted
    effective_at && effective_at.strftime("%d/%m/%Y")
  end

  def end_date_formatted
    end_date && end_date.strftime("%d/%m/%Y")
  end

  def self.search query
    if query.present?
      where("UPPER(events.name) LIKE UPPER(:query)
            OR UPPER(events.description) LIKE UPPER(:query)", 
            :query => "%#{query}%")
    else
      scoped
    end
  end

  def activate!
    update_attributes(:is_current => true)
  end

  def deactivate!
    update_attributes(:is_current => false)
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
