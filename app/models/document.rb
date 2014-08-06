class Document < ActiveRecord::Base
  belongs_to :event
  belongs_to :language
  validates :title, presence: true
  validates :date, presence: true
  validates :is_public, presence: true
  # TODO validates inclusion of type in available types
end
