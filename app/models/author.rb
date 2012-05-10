# == Schema Information
#
# Table name: authors
#
#  id          :integer         not null, primary key
#  first_name  :string(255)
#  middle_name :string(255)
#  last_name   :string(255)     not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Author < ActiveRecord::Base
  attr_accessible :first_name, :middle_name, :last_name
end
