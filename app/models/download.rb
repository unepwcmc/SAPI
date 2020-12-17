# == Schema Information
#
# Table name: downloads
#
#  id           :integer          not null, primary key
#  doc_type     :string(255)
#  format       :string(255)
#  status       :string(255)      default("working")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  path         :string(255)
#  filename     :string(255)
#  display_name :string(255)
#

class Download < ActiveRecord::Base
  attr_accessible :format, :doc_type

  validates :format, :presence => true, :inclusion => { :in => %w(pdf csv json zip) }
  validates :doc_type, :presence => true, :inclusion => { :in => %w(history index citesidmanual) }

  COMPLETED = 'completed'
  FAILED    = 'failed'
  WORKING   = 'working'
end
