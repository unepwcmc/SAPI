# == Schema Information
#
# Table name: documents
#
#  id                           :integer          not null, primary key
#  title                        :text             not null
#  filename                     :text             not null
#  date                         :date             not null
#  type                         :string(255)      not null
#  is_public                    :boolean          default(FALSE), not null
#  event_id                     :integer
#  language_id                  :integer
#  elib_legacy_id               :integer
#  created_by_id                :integer
#  updated_by_id                :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  sort_index                   :integer
#  primary_language_document_id :integer
#  elib_legacy_file_name        :text
#  original_id                  :integer
#  discussion_id                :integer
#  discussion_sort_index        :integer
#  designation_id               :integer
#

class Document < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search_by_title, :against => :title,
    :using => { :tsearch => { :prefix => true } },
    :order_within_rank => "documents.date, documents.title, documents.id"
  track_who_does_it
  attr_accessible :event_id, :filename, :date, :type, :title, :is_public,
    :language_id, :citations_attributes,
    :sort_index, :discussion_id, :discussion_sort_index,
    :primary_language_document_id,
    :designation_id
  belongs_to :designation
  belongs_to :event
  belongs_to :language
  belongs_to :primary_language_document, class_name: 'Document',
    foreign_key: 'primary_language_document_id'
  has_many :secondary_language_documents, class_name: 'Document',
    foreign_key: 'primary_language_document_id',
    dependent: :nullify
  has_many :citations, class_name: 'DocumentCitation', dependent: :destroy
  has_many :eu_opinions
  has_and_belongs_to_many :tags, class_name: 'DocumentTag', join_table: 'document_tags_documents'
  validates :title, presence: true
  validates :date, presence: true
  validates_uniqueness_of :primary_language_document_id, scope: :language_id, allow_nil: true
  # TODO: validates inclusion of type in available types
  accepts_nested_attributes_for :citations, :allow_destroy => true,
    :reject_if => proc { |attributes|
      attributes['stringy_taxon_concept_ids'].blank? && (
        attributes['geo_entity_ids'].blank? || attributes['geo_entity_ids'].reject(&:blank?).empty?
      )
    }
  mount_uploader :filename, DocumentFileUploader

  before_validation :set_title
  before_validation :reset_designation_if_event_set

# order docs based on a custom list of ids
  scope :for_ids_with_order, ->(ids) {
    order = sanitize_sql_array(
      ["position((',' || id::text || ',') in ?)", ids.join(',') + ',']
    )
    where(id: ids).order(order)
  }

  # This hot fix was needed to import document objects without attachment(external link)
  # Kepping this code just as reference for future
  # def filename=(arg)
  #   is_link? ? write_attribute(:filename, arg) : super
  # end
  #
  # def filename
  #   if self.has_attribute? :type
  #     is_link? ? read_attribute(:filename) : super
  #   else
  #     super
  #   end
  # end

  def is_link?
    self.type == 'Document::VirtualCollege' && !is_pdf?
  end

  def self.display_name
    'Document'
  end

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
    if title.blank? && self.changed? && filename.file
      self.title = filename.file.filename.sub(/.\w+$/, '').humanize
    end
  end

  def reset_designation_if_event_set
    if event.present? && event.designation.present?
      self.designation = event.designation
    end
  end

  def date_formatted
    date && Date.parse(date.to_s).strftime("%d/%m/%Y")
  end

  def taxon_names
    (read_attribute(:taxon_names) || []).compact
  end

  def geo_entity_names
    (read_attribute(:geo_entity_names) || []).compact
  end

  private

  def is_pdf?
    attr = elib_legacy_file_name || filename.file.filename
    (attr =~ /\.pdf/).present?
  end

end
