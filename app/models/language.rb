# == Schema Information
#
# Table name: languages
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  abbreviation :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Language < ActiveRecord::Base
  attr_accessible :abbreviation, :name
end
