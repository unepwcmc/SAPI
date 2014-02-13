class QuotasCopyWorker
  include Sidekiq::Worker
  def perform(options)
    ActiveRecord::Base.connection.execute <<-SQL
      SELECT * FROM copy_quotas_across_years(
        #{options["from_year"].to_i},
        '#{options["start_date"]}'::DATE,
        '#{options["end_date"]}'::DATE,
        '#{options["publication_date"]}'::DATE,
        ARRAY[#{options["excluded_taxon_concepts_ids"]}]::integer[],
        ARRAY[#{options["included_taxon_concepts_ids"]}]::integer[],
        #{if options["excluded_geo_entities_ids"]
            "ARRAY#{options["excluded_geo_entities_ids"].map(&:to_i)}"
          else
            "ARRAY[]::integer[]"
          end
        },
        #{if options["included_geo_entities_ids"]
            "ARRAY#{options["included_geo_entities_ids"].map(&:to_i)}"
          else
            "ARRAY[]::integer[]"
          end
        }
      )
    SQL
  end
end
