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
    # TODO taxonomy_id missing
  }

  def self.dashboard_download(params)
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
        "SELECT #{ATTRIBUTES.join(',')} FROM non_compliant_shipments_view WHERE year >= '2012' AND year <= '2016'"
      end
    query_runner(query)
  end

  def self.search_download(params)
    id = params[:ids]
    year = params[:year]
    query =
      case params[:type]
      when 'countries'
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

  def self.sanitize_compliance_param(param)
    if param.include?('trade')
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
