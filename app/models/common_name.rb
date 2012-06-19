# == Schema Information
#
# Table name: common_names
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  reference_id :integer
#  language_id  :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class CommonName < ActiveRecord::Base
  attr_accessible :language_id, :name, :reference_id
end
