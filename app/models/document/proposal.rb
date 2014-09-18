class Document::Proposal < Document
  def self.display_name; 'Proposal'; end

  attr_accessible :proposal_details_attributes

  has_one :proposal_details,
    :class_name => 'Document::ProposalDetails',
    :foreign_key => 'document_id'
  accepts_nested_attributes_for :proposal_details, :allow_destroy => true
end
