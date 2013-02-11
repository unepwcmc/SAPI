# == Schema Information
#
# Table name: annotations
#
#  id                :integer          not null, primary key
#  symbol            :string(255)
#  parent_symbol     :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  listing_change_id :integer
#

class Annotation < ActiveRecord::Base
  attr_accessible :listing_change_id, :symbol, :parent_symbol, :short_note_en,
    :full_note_en, :short_note_fr, :full_note_fr, :short_note_es, :full_note_es,
    :display_in_index, :display_in_footnote
  belongs_to :listing_change
  translates :short_note
  translates :full_note
end
