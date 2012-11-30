class TimelineEvent
  attr_accessor :change_type_name, :effective_at, :party_id, :pos
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
    @effective_at_formatted = options[:effective_at_formatted]
    @is_current = options[:is_current]
    @species_listing_name = options[:species_listing_name]
  end
end