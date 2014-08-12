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
  track_who_does_it
  attr_accessible :event_id, :filename, :date, :type, :title, :is_public, :language_id
  belongs_to :event
  belongs_to :language
  validates :title, presence: true
  validates :date, presence: true
  # TODO validates inclusion of type in available types
  mount_uploader :filename, DocumentFileUploader

  before_validation :set_title, on: :create

  def set_title
    self.title = filename.file.filename.sub(/.\w+$/, '').humanize
  end

  def date_formatted
    date && date.strftime("%d/%m/%Y")
  end

end
