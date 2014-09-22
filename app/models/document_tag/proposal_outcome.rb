class DocumentTag::ProposalOutcome < DocumentTag

  def self.display_name; 'Proposal outcome'; end

  def self.elibrary_document_types
    [Document::Proposal]
  end

end
