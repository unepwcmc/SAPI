# == Schema Information
#
# Table name: reference_authors
#
#  id           :integer         not null, primary key
#  reference_id :integer         not null
#  author_id    :integer         not null
#  index        :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class ReferenceAuthor < ActiveRecord::Base
  # attr_accessible :title, :body
end
