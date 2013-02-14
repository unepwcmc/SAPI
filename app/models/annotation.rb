# == Schema Information
#
# Table name: annotations
#
#  id                  :integer          not null, primary key
#  symbol              :string(255)
#  parent_symbol       :string(255)
#  listing_change_id   :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  short_note_en       :text
#  full_note_en        :text
#  short_note_fr       :text
#  full_note_fr        :text
#  short_note_es       :text
#  full_note_es        :text
#  display_in_index    :boolean          default(FALSE), not null
#  display_in_footnote :boolean          default(FALSE), not null
#

class Annotation < ActiveRecord::Base
  attr_accessible :listing_change_id, :symbol, :parent_symbol, :short_note_en,
    :full_note_en, :short_note_fr, :full_note_fr, :short_note_es, :full_note_es,
    :display_in_index, :display_in_footnote
  belongs_to :listing_change
  translates :short_note, :full_note
end
