module ParsePgArray
  def parse_array(attribute)
    attr = read_attribute(attribute)
    # --- []\n is the default value for tag_list in NomenclatureChange::Output
    return [] unless attr.present?
    return [] if attr.is_a?(String) && attr.match(/--- \[\]\n/).present?
    attr.map(&:to_s)
  end
end
