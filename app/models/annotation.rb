# == Schema Information
#
# Table name: annotations
#
#  id                  :integer          not null, primary key
#  symbol              :string(255)
#  parent_symbol       :string(255)
#  display_in_index    :boolean          default(FALSE), not null
#  display_in_footnote :boolean          default(FALSE), not null
#  short_note_en       :text
#  full_note_en        :text
#  short_note_fr       :text
#  full_note_fr        :text
#  short_note_es       :text
#  full_note_es        :text
#  source_id           :integer
#  event_id            :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  import_row_id       :integer
#

class Annotation < ActiveRecord::Base
  attr_accessible :listing_change_id, :symbol, :parent_symbol, :short_note_en,
    :full_note_en, :short_note_fr, :full_note_fr, :short_note_es, :full_note_es,
    :display_in_index, :display_in_footnote, :event_id
  belongs_to :listing_change
  belongs_to :event
  translates :short_note, :full_note

  scope :for_cites, joins(:event).where("events.type = 'CitesCop'").
    order([:parent_symbol, :symbol])
  scope :for_eu, joins(:event).where("events.type = 'EuRegulation'").
    order([:parent_symbol, :symbol])

  def self.search query
    if query
      where("UPPER(symbol) LIKE UPPER(:query)
            OR UPPER(parent_symbol) LIKE UPPER(:query)
            OR UPPER(short_note_en) LIKE UPPER(:query)
            OR UPPER(full_note_en) LIKE UPPER(:query)
            OR UPPER(short_note_fr) LIKE UPPER(:query)
            OR UPPER(full_note_fr) LIKE UPPER(:query)
            OR UPPER(short_note_es) LIKE UPPER(:query)
            OR UPPER(full_note_es) LIKE UPPER(:query)
            OR UPPER(description) LIKE UPPER(:query)",
            :query => "%#{query}%")
    else
      scoped
    end
  end

  def full_symbol
    "#{parent_symbol}#{symbol}"
  end

end
