  # 'taxonomy' => {'id' => x}
  # 'rank' => {'id' => x, 'scope' => [parent|ancestors]}
  # 'taxon_concept' => {'id' => x, 'scope' => [ancestors]}
  # 'scientific_name'
class SearchParams
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  attr_accessor :taxonomy, :rank, :taxon_concept, :scientific_name

  def initialize(attributes = {})
    attributes.each do |name, value|
      #send("#{name}=", (value.is_a?(Hash) ? value.symbolize_keys : value))
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

end
