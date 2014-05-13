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
  include SentientUser
  track_who_does_it
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable
  attr_accessible :email, :name, :password, :password_confirmation,
    :remember_me

  validates :email, :uniqueness => true, :presence => true
  validates :name, :presence => true

end
