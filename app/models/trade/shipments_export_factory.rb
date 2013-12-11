class Trade::ShipmentsExportFactory
  def self.new(filters)
    filters ||= {}
    filters = filters.merge({:locale => I18n.locale})
    puts filters.inspect
    @report_type = filters && filters[:report_type] &&
      filters[:report_type].downcase.strip.to_sym
    unless [
      :raw, :comptab, :gross_exports, :gross_imports,
      :net_exports, :net_imports
    ].include? @report_type
      @report_type = :comptab
    end
    case @report_type
      when :comptab
        filters = filters.delete_if do |k,v|
          ['quantity', 'permits_ids', 'reporter_type'].include? k
        end
        Trade::ShipmentsComptabExport.new(filters)
      when :gross_exports
        filters = filters.delete_if do |k,v|
          ['quantity', 'permits_ids', 'reporter_type', 'purpose_id', 'source_id'].include? k
        end
        Trade::ShipmentsGrossExportsExport.new(filters)
      when :gross_imports
        filters = filters.delete_if do |k,v|
          ['quantity', 'permits_ids', 'reporter_type', 'purpose_id', 'source_id'].include? k
        end
        Trade::ShipmentsGrossImportsExport.new(filters)
      when :net_exports
        filters = filters.delete_if do |k,v|
          ['quantity', 'permits_ids', 'reporter_type', 'purpose_id', 'source_id'].include? k
        end
        Trade::ShipmentsNetExportsExport.new(filters)
      when :net_imports
        filters = filters.delete_if do |k,v|
          ['quantity', 'permits_ids', 'reporter_type', 'purpose_id', 'source_id'].include? k
        end
        Trade::ShipmentsNetImportsExport.new(filters)
      else
        Trade::ShipmentsExport.new(filters)
    end
  end
end
