# == Schema Information
#
# Table name: annotations
#
#  id                  :integer          not null, primary key
#  display_in_footnote :boolean          default(FALSE), not null
#  display_in_index    :boolean          default(FALSE), not null
#  full_note_en        :text
#  full_note_es        :text
#  full_note_fr        :text
#  parent_symbol       :string(255)
#  short_note_en       :text
#  short_note_es       :text
#  short_note_fr       :text
#  symbol              :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  created_by_id       :integer
#  event_id            :integer
#  import_row_id       :integer
#  original_id         :integer
#  updated_by_id       :integer
#
# Indexes
#
#  index_annotations_on_created_by_id  (created_by_id)
#  index_annotations_on_event_id       (event_id)
#  index_annotations_on_original_id    (original_id)
#  index_annotations_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  annotations_created_by_id_fk  (created_by_id => users.id)
#  annotations_event_id_fk       (event_id => events.id)
#  annotations_source_id_fk      (original_id => annotations.id)
#  annotations_updated_by_id_fk  (updated_by_id => users.id)
#

class Annotation < ApplicationRecord
  include Deletable
  extend Mobility
  include TrackWhoDoesIt

  # Migrated to controller (Strong Parameters)
  # attr_accessible :listing_change_id, :symbol, :parent_symbol, :short_note_en,
  #   :full_note_en, :short_note_fr, :full_note_fr, :short_note_es, :full_note_es,
  #   :display_in_index, :display_in_footnote, :event_id

  has_many :listing_changes,
    dependent: :nullify

  has_many :hashed_listing_changes,
    class_name: 'ListingChange',
    dependent: :nullify,
    foreign_key: :hash_annotation_id,
    inverse_of: :hash_annotation

  belongs_to :event, optional: true
  translates :short_note, :full_note

  scope :for_cites, -> do
    joins(:event).where(
      "events.type = 'CitesCop'"
    ).order(
      [ :parent_symbol, :symbol ]
    )
  end

  scope :for_eu, -> {
    joins(:event).where(
      "events.type = 'EuRegulation'"
    ).order(
      [ :parent_symbol, :symbol ]
    )
  }

  # If this pattern is not respected, a query which parses (most of) the
  # symbol as an integer
  #
  # OK: '^1', '#33'; not ok '#18edit'
  validates :symbol, presence: false, format: {
    allow_blank: true,
    message: 'should be a symbol followed by one or more digits',
    with: /\A[^0-9a-z\s]\d+\z/i
  }

  # cannot make [ :parent_symbol, :symbol ] unique - see https://unep-wcmc.codebasehq.com/projects/cites-support-maintenance/tickets/282

  before_save do
    if event
      self.parent_symbol = event.name
    end
  end

  def self.search(query)
    self.ilike_search(
      query, [
        *searchable_text_columns,

        query && Arel::Nodes::Concat.new(
          arel_table['parent_symbol'],
          arel_table['symbol']
        ).matches(
          "%#{sanitize_sql_like(query)}%"
        )
      ]
    )
  end

  def full_symbol
    "#{parent_symbol}#{symbol}"
  end

  def self.ignored_attributes
    super + [ :import_row_id, :original_id ]
  end

  def self.text_attributes
    [
      :short_note_en, :short_note_es, :short_note_fr,
      :full_note_en, :full_note_es, :full_note_fr,
      :symbol, :parent_symbol
    ]
  end

private

  def dependent_objects_map
    {
      'listing changes' => listing_changes,
      '# listing_changes' => hashed_listing_changes
    }
  end
end
