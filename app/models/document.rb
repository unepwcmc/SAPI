# == Schema Information
#
# Table name: documents
#
#  id               :integer               not null, primary key
#  title            :text                  not null
#  filename         :text
#  date             :date                  not null
#  type             :character_varying
#  is_public        :boolean               not null
#  event_id         :integer
#  language_id      :integer
#  legacy_id        :integer
#  created_by_id    :integer
#  updated_by_id    :integer
#

class Document < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search_by_title, :against => :title,
    :using => {:tsearch => {:prefix => true}}
  track_who_does_it
  attr_accessible :event_id, :filename, :date, :type, :title, :is_public,
    :language_id, :citations_attributes
  belongs_to :event
  belongs_to :language
  has_many :citations, class_name: 'DocumentCitation', dependent: :destroy
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

  def set_title
    if title.blank? && filename_changed?
      self.title = filename.file.filename.sub(/.\w+$/, '').humanize
    end
  end

  def date_formatted
    date && date.strftime("%d/%m/%Y")
  end

end
