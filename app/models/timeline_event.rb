class TimelineEvent
  attr_accessor :change_type_name, :effective_at, :pos
  #options to be passed:
  #:change_type_name
  #:effective_at
  #:generic_notes may be rich text (html)
  #:specific_notes may be rich text (html)
  #:symbol e.g. #4
  #:parent_symbol e.g. CoP15
  #:pos - position (%)
  def initialize(options)
    @id = object_id
    @pos = options[:pos]
    @party = options[:party]
    @change_type_name = options[:change_type_name]
    @specific_notes = options[:specific_notes]
    @generic_notes = options[:generic_notes]
    @symbol = options[:symbol]
    @parent_symbol = options[:parent_symbol]
    @effective_at = options[:effective_at].strftime("%d/%m/%y")
  end
end