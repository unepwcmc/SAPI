class TimelineEvent
  attr_accessor :change_type_name, :effective_at, :pos
  #options to be passed:
  #:change_type_name
  #:effective_at
  #:is_current
  #:generic_notes may be rich text (html)
  #:specific_notes may be rich text (html)
  #:symbol e.g. #4
  #:parent_symbol e.g. CoP15
  #:pos - position (%)
  def initialize(options)
    @id = object_id
    @pos = options[:pos]
    @party_id = options[:party_id]
    @change_type_name = options[:change_type_name]
    @specific_note = options[:specific_note]
    @generic_note = options[:generic_note]
    @symbol = options[:symbol]
    @parent_symbol = options[:parent_symbol]
    @effective_at = options[:effective_at]
    @is_current = options[:is_current]
  end
end