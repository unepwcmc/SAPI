class Document::ReviewOfSignificantTrade < Document
  def self.display_name; 'Review of Significant Trade'; end

  attr_accessible :review_details_attributes

  has_one :review_details,
    :class_name => 'Document::ReviewDetails',
    :foreign_key => 'document_id'
  accepts_nested_attributes_for :review_details, :allow_destroy => true
end
