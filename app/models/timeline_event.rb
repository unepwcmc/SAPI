class TimelineEvent
  include ActiveModel::Serializers::JSON
  attr_accessor :id, :change_type_name, :species_listing_name, :effective_at,
    :party_id, :is_current, :pos, :specific_short_note, :specific_full_note,
    :generic_note, :symbol, :parent_symbol
  #options to be passed:
  #:change_type_name
  #:effective_at
  #:is_current
  #:generic_note may be rich text (html)
  #:specific_short_note
  #:specific_full_note may be rich text (html)
  #:symbol e.g. #4
  #:parent_symbol e.g. CoP15
  #:pos - position (%)
  def initialize(options)
    @id = object_id
    @pos = options[:pos]
    @party_id = options[:party_id]
    @change_type_name = options[:change_type_name]
    @specific_short_note = options[:specific_short_note]
    @specific_full_note = options[:specific_full_note]
    @generic_note = options[:generic_note]
    @symbol = options[:symbol]
    @parent_symbol = options[:parent_symbol]
    @effective_at = options[:effective_at]
    @is_current = options[:is_current]
    @species_listing_name = options[:species_listing_name]
  end

  def attributes
    {
      'id' => id,
      'change_type_name' => change_type_name,
      'species_listing_name' => species_listing_name,
      'effective_at_formatted' => effective_at_formatted,
      'party_id' => party_id,
      'is_current' => is_current,
      'specific_short_note' => specific_short_note,
      'specific_full_note' => specific_full_note,
      'generic_note' => generic_note,
      'symbol' => symbol,
      'parent_symbol' => parent_symbol,
      'pos' => pos
    }
  end

  def is_addition?
    @change_type_name == ChangeType::ADDITION
  end

  def is_deletion?
    @change_type_name == ChangeType::DELETION
  end

  def is_reservation?
    [ChangeType::RESERVATION, ChangeType::RESERVATION_WITHDRAWAL].include? @change_type_name
  end

  def effective_at_formatted
    effective_at.strftime("%d/%m/%y")
  end

end