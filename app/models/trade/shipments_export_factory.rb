class Trade::ShipmentsExportFactory
  def self.new(filters)
    filters ||= {}
    filters = filters.merge({ :locale => I18n.locale })
    @report_type = filters[:report_type]
    unless report_types.include? @report_type
      @report_type = :comptab
    end
    case @report_type
    when :comptab
      Trade::ShipmentsComptabExport.new(filters)
    when :gross_exports
      Trade::ShipmentsGrossExportsExport.new(filters)
    when :gross_imports
      Trade::ShipmentsGrossImportsExport.new(filters)
    when :net_exports
      Trade::ShipmentsNetExportsExport.new(filters)
    when :net_imports
      Trade::ShipmentsNetImportsExport.new(filters)
    else
      Trade::ShipmentsExport.new(filters)
    end
  end

  def self.report_types
    public_report_types + [:raw]
  end

  def self.public_report_types
    [:comptab, :gross_exports, :gross_imports, :net_exports, :net_imports]
  end

end
