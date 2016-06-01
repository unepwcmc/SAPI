class Species::ListingsExportFactory
  def self.new(filters = {})
    @designation =
      if filters[:designation_id]
        Designation.find(filters[:designation_id])
      elsif filters[:designation]
        Designation.find_by_name(filters[:designation].upcase)
      end
    if @designation && @designation.name == 'CMS'
      Species::CmsListingsExport.new(@designation, filters)
    elsif @designation && @designation.name == 'EU'
      Species::EuListingsExport.new(@designation, filters)
    else
      Species::CitesListingsExport.new(@designation, filters)
    end
  end
end
