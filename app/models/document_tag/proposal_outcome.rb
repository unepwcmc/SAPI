# == Schema Information
#
# Table name: document_tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DocumentTag::ProposalOutcome < DocumentTag

  def self.display_name; 'Proposal outcome'; end

  def self.elibrary_document_types
    [Document::Proposal]
  end

end
