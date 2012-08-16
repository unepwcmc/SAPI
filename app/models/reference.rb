# == Schema Information
#
# Table name: references
#
#  id          :integer          not null, primary key
#  title       :text             not null
#  year        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  author      :string(255)
#  legacy_id   :integer
#  legacy_type :string(255)
#

class Reference < ActiveRecord::Base
  attr_accessible :title, :author, :year
end
