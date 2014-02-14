class QuotasCopyWorker
  include Sidekiq::Worker
  def perform(options)
    sql = <<-SQL
        SELECT * FROM copy_quotas_across_years(
          :from_year,
          :start_date::DATE,
          :end_date::DATE,
          :publication_date::DATE,
          ARRAY[:excluded_taxon_concepts_ids]::integer[],
          ARRAY[:included_taxon_concepts_ids]::integer[],
          ARRAY[:excluded_geo_entities_ids]::integer[],
          ARRAY[:included_geo_entities_ids]::integer[]
        )
      SQL
    ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.send(:sanitize_sql_array, [sql,
        :from_year => options["from_year"], :start_date => options["start_date"],
        :end_date =>options["end_date"],
        :publication_date => options["publication_date"],
        :excluded_taxon_concepts_ids => options["excluded_taxon_concepts_ids"].presence,
        :included_taxon_concepts_ids => options["included_taxon_concepts_ids"].presence,
        :excluded_geo_entities_ids => (options["excluded_geo_entities_ids"] && 
                                       options["excluded_geo_entities_ids"].join(",")),
        :included_geo_entities_ids => (options["included_geo_entities_ids"] &&
                                       options["included_geo_entities_ids"].join(","))
    ]))
  end
end
