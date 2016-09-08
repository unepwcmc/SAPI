# == Schema Information
#
# Table name: document_tags
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DocumentTag::Discussion < DocumentTag

  def self.display_name
    'Discussion'
  end

end
