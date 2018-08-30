module Trade::DownloadDataRetriever

  ATTRIBUTES = %w[id year appendix taxon_name taxon_concept_id class_name order_name family_name genus_name
                  term term_id importer_reported_quantity exporter_reported_quantity
                  unit importer importer_iso importer_id exporter exporter_iso exporter_id origin
                  purpose source import_permit export_permit origin_permit
                  issue_type rank_name].freeze

  ID_MAPPING = {
    commodity: 'term_id',
    exporting: 'exporter_id',
    importing: 'importer_id',
    species: 'taxon_concept_id'
  }

  def self.dashboard_download(params)
    return taxonomic_download(params) if params[:type] == 'taxonomy'
    query =
      if params[:year].present?
        if params[:type].present?
          "SELECT #{ATTRIBUTES.join(',')} FROM non_compliant_shipments_view WHERE year = #{params[:year]} AND #{ID_MAPPING[params[:type].to_sym]} IN (#{params[:ids]})"
        elsif params[:compliance_type].present?
          "SELECT #{ATTRIBUTES.join(',')} FROM non_compliant_shipments_view WHERE year = #{params[:year]} AND issue_type = '#{sanitize_compliance_param(params[:compliance_type])}'"
        else
          "SELECT #{ATTRIBUTES.join(',')} FROM non_compliant_shipments_view WHERE year = #{params[:year]}"
        end
      else
        "SELECT #{ATTRIBUTES.join(',')} FROM non_compliant_shipments_view WHERE year >= '2012' AND year <= '2017'"
      end
    query_runner(query)
  end

  def self.search_download(params)
    id = params[:ids]
    year = params[:year]
    return [] if id.empty?
    query =
      case params[:group_by]
      when 'exporting'
        <<-SQL
               SELECT #{ATTRIBUTES.join(',')}
               FROM non_compliant_shipments_view
               WHERE year = #{year}
               AND (exporter_id IN (#{id}) OR importer_id IN (#{id}))
        SQL
      when 'species'
        <<-SQL
               SELECT #{ATTRIBUTES.join(',')}
               FROM non_compliant_shipments_view
               WHERE year = #{year}
               AND taxon_concept_id IN (#{id})
        SQL
      when 'commodity'
        <<-SQL
               SELECT #{ATTRIBUTES.join(',')}
               FROM non_compliant_shipments_view
               WHERE year = #{year}
               AND term_id IN (#{id})
        SQL
      end
    query_runner(query)
  end

  def self.taxonomic_download(params)
    mapping = Trade::ComplianceGrouping.new('').read_taxonomy_conversion
    array_ids = []
    mapping[params[:ids]].each do |m|
      rank_name = m[:rank] == 'Species' ? 'taxon' : m[:rank].downcase

      ids_query = ids_query(params[:year], params[:ids], rank_name, m[:taxon_name])
      ids = query_runner(ids_query)

      ids.each { |ob| array_ids << ob['id'] }
      array_ids = plant_timber_distinction(params[:year], mapping, array_ids) if params[:ids].include?('Plants')
    end
    return if array_ids.empty?
    query = "SELECT #{ATTRIBUTES.join(',')}
             FROM non_compliant_shipments_view
             WHERE year = #{params[:year]}
             AND id IN (#{array_ids.join(',')})"
    query_runner(query)
  end

  def self.ids_query(year, id, rank, taxon)
    "SELECT id FROM non_compliant_shipments_view
     WHERE year = #{year}
     AND #{ids_query_condition(id, rank, taxon)}"
  end

  def self.ids_query_condition(id, rank, taxon)
    id.include?('Plants') ? 'class_id IS NULL' : "#{rank}_name = '#{taxon}'"
  end

  def self.plant_timber_distinction(year, mapping, array)
    timber_ids = []
    mapping['Timber'].each do |mapp|
      rank_name = mapp[:rank] == 'Species' ? 'taxon' : mapp[:rank].downcase
      ids_query = ids_query(year, 'Timber', rank_name, mapp[:taxon_name])
      ids = query_runner(ids_query)
      ids.each { |ob| timber_ids << ob['id'] }
    end
    array.reject { |el| timber_ids.include? el }
  end

  def self.sanitize_compliance_param(param)
    if param.include?('suspension')
      'Suspension'
    elsif param.include?('quota')
      'Quota'
    elsif param.include?('appendix')
      'AppendixI'
    end
  end

  def self.query_runner(query)
    ActiveRecord::Base.connection.execute(query)
  end
end
