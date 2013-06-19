# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  email      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name

  validates :email, :uniqueness => true, :presence => true
  validates :name, :presence => true

  def can_be_deleted?
    false #TODO
  end

end
