# == Schema Information
#
# Table name: references
#
#  id          :integer          not null, primary key
#  title       :text             not null
#  year        :string(255)
#  author      :string(255)
#  legacy_id   :integer
#  legacy_type :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  citation    :text
#  publisher   :text
#

class Reference < ActiveRecord::Base
  attr_accessible :title, :author, :year

  validates :title, :presence => true

  scope :autocomplete, lambda { |q|
    where("title ILIKE ? OR
           author ILIKE ? OR
           year ILIKE ?",
          "#{q}%", "#{q}%", "#{q}%")
  }
end
