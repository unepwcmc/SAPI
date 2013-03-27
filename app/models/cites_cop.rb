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
#

class CitesCop < Event
  validates :designation_id, :presence => true
  validate :designation_is_cites
  validates :effective_at, :presence => true

  protected
    def designation_is_cites
      cites = Designation.find_by_name('CITES')
      unless designation_id && cites && designation_id == cites.id
        errors.add(:designation_id, 'should be CITES')
      end
    end
end
