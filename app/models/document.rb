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
  belongs_to :event
  belongs_to :language
  validates :title, presence: true
  validates :date, presence: true
  validates :is_public, presence: true
  # TODO validates inclusion of type in available types
end
