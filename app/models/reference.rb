# == Schema Information
#
# Table name: references
#
#  id         :integer          not null, primary key
#  title      :string(255)      not null
#  year       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Reference < ActiveRecord::Base
  attr_accessible :title, :author, :year
  has_and_belongs_to_many :designations, :join_table => :designation_references
end
