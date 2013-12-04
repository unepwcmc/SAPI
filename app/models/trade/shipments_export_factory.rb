class Trade::ShipmentsExportFactory
  def self.new(filters)
    filters ||= {}
    puts filters.inspect
    @report_type = filters && filters[:report_type] &&
      filters[:report_type].downcase.strip.to_sym
    unless [:raw, :comptab, :net_gross].include? @report_type
      @report_type = :comptab
    end
    case @report_type
      when :comptab
        raise "comptab is not implemented yet"
      when :net_gross
        raise "net/gross is not implemented yet"
      else
        Trade::ShipmentsExport.new(filters)
    end
  end
end
