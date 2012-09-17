class TimelineEvent
  attr_accessor :change_type_name, :effective_at, :pos
  #options to be passed:
  #:change_type_name
  #:effective_at
  #:pos - position (%)
  def initialize(options)
    @id = object_id
    @pos = options[:pos]
    @change_type_name = options[:change_type_name]
    @effective_at = options[:effective_at]
  end
end