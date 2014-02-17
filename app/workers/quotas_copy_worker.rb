class QuotasCopyWorker
  include Sidekiq::Worker
  def perform(options)
    sql = <<-SQL
        SELECT * FROM copy_quotas_across_years(
          :from_year,
          :start_date,
          :end_date,
          :publication_date,
          ARRAY[:excluded_taxon_concepts_ids]::integer[],
          ARRAY[:included_taxon_concepts_ids]::integer[],
          ARRAY[:excluded_geo_entities_ids]::integer[],
          ARRAY[:included_geo_entities_ids]::integer[],
          :from_text,
          :to_text
        )
      SQL
    ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.send(:sanitize_sql_array, [sql,
        :from_year => options["from_year"],
        :start_date => Date.parse(options["start_date"]),
        :end_date => Date.parse(options["end_date"]),
        :publication_date => Date.parse(options["publication_date"]),
        :excluded_taxon_concepts_ids => options["excluded_taxon_concepts_ids"].presence,
        :included_taxon_concepts_ids => options["included_taxon_concepts_ids"].presence,
        :excluded_geo_entities_ids => (options["excluded_geo_entities_ids"] && 
                                       options["excluded_geo_entities_ids"].join(",")),
        :included_geo_entities_ids => (options["included_geo_entities_ids"] &&
                                       options["included_geo_entities_ids"].join(",")),
        :from_text => options["from_text"],
        :to_text => options["to_text"]
    ]))
  end
end
