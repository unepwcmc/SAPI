class Trade::Grouping::NoGroupingAttributeError < StandardError

  ERROR_MESSAGE = "Grouping attribute not specified! Using 'year' by default.".freeze
  def initialize(msg=ERROR_MESSAGE)
    super
  end
end
