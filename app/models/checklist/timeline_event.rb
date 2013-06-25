class Checklist::TimelineEvent
  include ActiveModel::SerializerSupport
  attr_accessor :id, :change_type_name, :species_listing_name, :effective_at,
    :party_id, :is_current, :pos, :short_note_en, :full_note_en,
    :hash_full_note_en, :hash_ann_symbol, :hash_ann_parent_symbol
  #options to be passed:
  #:change_type_name
  #:effective_at
  #:is_current
  #:hash_full_note_en may be rich text (html)
  #:short_note_en may be rich text (html)
  #:full_note_en may be rich text (html)
  #:hash_ann_symbol e.g. #4
  #:hash_ann_parent_symbol e.g. CoP15
  #:pos - position (%)
  def initialize(options)
    @id = object_id
    @pos = options[:pos]
    @party_id = options[:party_id]
    @change_type_name = options[:change_type_name]
    @short_note_en = options[:short_note_en]
    @full_note_en = options[:full_note_en]
    @hash_full_note_en = options[:hash_full_note_en]
    @hash_ann_symbol = options[:hash_ann_symbol]
    @effective_at = options[:effective_at]
    @is_current = options[:is_current]
    @species_listing_name = options[:species_listing_name]
  end

  def is_addition?
    @change_type_name == ChangeType::ADDITION
  end

  def is_deletion?
    @change_type_name == ChangeType::DELETION
  end

  def is_reservation?
    @change_type_name == ChangeType::RESERVATION
  end

  def is_reservation_withdrawal?
    @change_type_name == ChangeType::RESERVATION_WITHDRAWAL
  end

  def effective_at_formatted
    effective_at.strftime("%d/%m/%y")
  end

end
