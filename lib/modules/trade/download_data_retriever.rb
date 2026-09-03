module Trade::DownloadDataRetriever
  ATTRIBUTES = %w[
    id year appendix taxon_name class_name order_name family_name genus_name
    term importer_reported_quantity exporter_reported_quantity
    unit importer exporter origin purpose source
    import_permit export_permit origin_permit ifs_permit issue_type
  ].freeze

  ID_MAPPING = {
    commodity: 'term_id',
    exporting: 'exporter_id',
    importing: 'importer_id',
    species: 'taxon_concept_id'
  }

  def self.dashboard_download(params)
    return taxonomic_download(params) if params[:type] == 'taxonomy'

    default_year_range = 2012..(Date.today.year - 1)

    query =
      Trade::NonCompliantShipmentsView.select(
        ATTRIBUTES
      ).where(
        [
          { year: params[:year].presence || default_year_range },

          if params[:type] == 'species'
            {
              taxon_concept_id: sanitise_integer_array(params[:ids], 'ids'),
              appendix: params[:appendix]&.split(',')
            }
          end,

          if params[:compliance_type].presence
            { issue_type: sanitize_compliance_param(params[:compliance_type]) }
          end
        ].compact.reduce(&:merge)
      ).order(
        year: :desc
      ).to_sql

    query_runner(query)
  end

  def self.search_download(params)
    ids = sanitise_integer_array(params[:ids], 'ids')
    year = params[:year]

    return [] if ids.empty?

    query_condition =
      case params[:group_by]
      when 'importing', 'exporting'
        arel_table = Trade::NonCompliantShipmentsView.arel_table

        arel_table[:exporter_id].in(ids).or(
          arel_table[:importer_id].in(ids)
        )
      when 'species'
        appendix = params[:appendix]
        if appendix.present?
          {
            taxon_concept_id: ids,
            appendix: appendix
          }
        else
          { taxon_concept_id: ids }
        end
      when 'commodity'
        { term_id: ids }
      else
        # We do not know what `ids` represents
        return []
      end

      query =
        Trade::NonCompliantShipmentsView.select(
          ATTRIBUTES
        ).where(
          year: year
        ).where(
          query_condition
        ).to_sql

    query_runner(query)
  end

  # - `params[:year]` required
  # - `params[:ids]` required: a group like 'Plants' (not sure why it's `ids`)
  def self.taxonomic_download(params)
    mapping = Trade::Grouping::Compliance.new().read_taxonomy_conversion
    array_ids = []

    mapping[params[:ids]].each do |m|
      rank_name = m[:rank] == 'Species' ? 'taxon' : m[:rank].downcase

      ids_query = ids_query(params[:year], params[:ids], rank_name, m[:taxon_name])
      ids = query_runner(ids_query)

      ids.each { |ob| array_ids << ob['id'] }
      array_ids = plant_timber_distinction(params[:year], mapping, array_ids) if params[:ids].include?('Plants')
    end

    return if array_ids.empty?

    query =
      Trade::NonCompliantShipmentsView.select(
        ATTRIBUTES
      ).where(
        year: params[:year],
        id: array_ids
      ).to_sql

    query_runner(query)
  end

  def self.ids_query(year, id, rank, taxon)
    Trade::NonCompliantShipmentsView.select(
      ATTRIBUTES
    ).where(
      year: year,
    ).where(
      if id.include?('Plants')
        { class_id: nil }
      else
        { "#{rank}_name": taxon }
      end
    ).to_sql
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
    ApplicationRecord.connection.execute(query)
  end

  def self.sanitise_integer_array(original, param_name_for_error)
    Trade::Grouping::Base.sanitise_integer_array(original, param_name_for_error)
  end
end
