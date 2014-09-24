class DocumentTag::ReviewPhase < DocumentTag

  def self.display_name; 'Review phase'; end

  def self.elibrary_document_types
    [Document::ReviewOfSignificantTrade]
  end

end
