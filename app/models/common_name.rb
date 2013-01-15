# == Schema Information
#
# Table name: common_names
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  language_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CommonName < ActiveRecord::Base
  attr_accessible :language_id, :name, :reference_id
  belongs_to :language
  validates :name, :presence => true

  def self.english_to_pdf common_name
    words = common_name.split
    return common_name if words.size == 1
    words.last + ", " + common_name.chomp(" "+words.last)
  end
end
