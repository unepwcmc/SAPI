module ParsePgArray
  def parse_array(attribute)
    # byebug
    attr = read_attribute(attribute)
    return [] unless attr.present?
    attr.map(&:to_s)
  end
end
