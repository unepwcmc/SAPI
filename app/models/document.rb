# == Schema Information
#
# Table name: documents
#
#  id            :integer          not null, primary key
#  title         :text             not null
#  filename      :text             not null
#  date          :date             not null
#  type          :string(255)      not null
#  is_public     :boolean          default(FALSE), not null
#  event_id      :integer
#  language_id   :integer
#  legacy_id     :integer
#  created_by_id :integer
#  updated_by_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  number        :string(255)
#

class Document < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search_by_title, :against => :title,
    :using => {:tsearch => {:prefix => true}},
    :order_within_rank => "documents.date, documents.title, documents.id"
  track_who_does_it
  attr_accessible :event_id, :filename, :date, :type, :title, :is_public,
    :language_id, :citations_attributes, :number
  belongs_to :event
  belongs_to :language
  has_many :citations, class_name: 'DocumentCitation', dependent: :destroy
  has_and_belongs_to_many :tags, class_name: 'DocumentTag', join_table: 'document_tags_documents'
  validates :title, presence: true
  validates :date, presence: true
  # TODO validates inclusion of type in available types
  accepts_nested_attributes_for :citations, :allow_destroy => true,
    :reject_if => proc { |attributes|
    attributes['stringy_taxon_concept_ids'].blank? && (
      attributes['geo_entity_ids'].blank? || attributes['geo_entity_ids'].reject(&:blank?).empty?
    )
  }
  mount_uploader :filename, DocumentFileUploader

  before_validation :set_title

  def self.display_name; 'Document'; end

  # Returns document types (class objects) that are relevant to E-Library
  def self.elibrary_document_types
    self.subclasses
  end

  # Returns event types (class objects) that are relevant to E-Library and
  # that can be associated with this document type
  def self.elibrary_event_types
    Event.elibrary_event_types.select do |e_klass|
      e_klass.elibrary_document_types.include? self
    end
  end

  # Returns document tag types (class objects) that are relevant to E-Library
  def self.elibrary_document_tag_types
    [DocumentTag::ProposalOutcome, DocumentTag::ReviewPhase, DocumentTag::ProcessStage]
  end

  def set_title
    if title.blank? && filename_changed?
      self.title = filename.file.filename.sub(/.\w+$/, '').humanize
    end
  end

  def date_formatted
    date && date.strftime("%d/%m/%Y")
  end

  def citations_cnt
    citations.map do |citation|
      taxon_concept_count = citation.document_citation_taxon_concepts.count
      geo_entity_count = citation.document_citation_geo_entities.count
      (
        (taxon_concept_count == 0 ? 1 : taxon_concept_count) *
        (geo_entity_count == 0 ? 1 : geo_entity_count)
      )
    end.reduce(:+) || 0
  end

end
