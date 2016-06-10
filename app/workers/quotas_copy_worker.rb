class QuotasCopyWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :admin, :retry => false, :backtrace => 50

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
          :to_text,
          :current_user_id,
          :url
        )
      SQL
    ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.send(:sanitize_sql_array, [
        sql,
        :from_year => options["from_year"],
        :start_date => Date.parse(options["start_date"]),
        :end_date => Date.parse(options["end_date"]),
        :publication_date => Date.parse(options["publication_date"]),
        :excluded_taxon_concepts_ids => (options["excluded_taxon_concepts_ids"].present? ?
          options["excluded_taxon_concepts_ids"].split(",").map(&:to_i) : nil),
        :included_taxon_concepts_ids => (options["included_taxon_concepts_ids"].present? ?
          options["included_taxon_concepts_ids"].split(",").map(&:to_i) : nil),
        :excluded_geo_entities_ids => (options["excluded_geo_entities_ids"] &&
                                       options["excluded_geo_entities_ids"].map(&:to_i)),
        :included_geo_entities_ids => (options["included_geo_entities_ids"] &&
                                       options["included_geo_entities_ids"].map(&:to_i)),
        :from_text => options["from_text"],
        :to_text => options["to_text"],
        :current_user_id => options["current_user_id"],
        :url => options["url"]
      ])
    )
  end
end
