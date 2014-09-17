class Document::ReviewOfSignificantTrade < Document
  has_one :review_details,
    :class_name => 'Document::ReviewDetails',
    :foreign_key => 'document_id'

  def self.display_name; 'Review of Significant Trade'; end
end
