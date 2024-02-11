module Import::Rst::Formatter
  class << self
    def format_data(data)
      data.map do |item|
        item.deep_slice('id', 'countryId', 'status', 'startDate', 'species' => 'name', 'meeting' => 'name')
      end
    end
  end
end
