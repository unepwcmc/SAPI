# with eu_opinions_without_ec_srg_match as (
#   select * from eu_decisions where type='EuOpinion'

#   except

#   select
#   -- ec_srgs.effective_at, ec_srgs.id,
#   eu_opinions.*
#   from eu_decisions eu_opinions
#   join events ec_srgs on ec_srgs.effective_at = eu_opinions.start_date
#   where eu_opinions.type='EuOpinion'
# )
# select
# 'https://speciesplus.net/admin/taxon_concepts/' || taxon_concept_id || '/eu_opinions/' || eu_opinions.id || '/edit' AS admin_url,
# taxon_concepts.full_name,
# geo_entities.name_en,
# eu_opinions.*
# from eu_opinions_without_ec_srg_match eu_opinions
# join taxon_concepts on taxon_concepts.id = eu_opinions.taxon_concept_id
# join geo_entities on geo_entities.id = eu_opinions.geo_entity_id
# order by start_date;

task :map_eu_opinions_to_ec_srgs => :environment do
  update_query = <<-SQL
    WITH eu_opinions_matching_with_ec_srgs AS (
      SELECT
      ec_srgs.effective_at, ec_srgs.id AS ec_srg_id,
      eu_opinions.*
      FROM eu_decisions eu_opinions
      JOIN events ec_srgs ON ec_srgs.effective_at = eu_opinions.start_date AND ec_srgs.type = 'EcSrg'
      WHERE eu_opinions.type='EuOpinion'
      AND (eu_opinions.start_event_id IS NULL OR eu_opinions.start_event_id != ec_srgs.id) -- so that it does not re-update at next run
    )
    UPDATE eu_decisions
    SET start_event_id = ec_srg_id
    FROM eu_opinions_matching_with_ec_srgs
    WHERE eu_opinions_matching_with_ec_srgs.id = eu_decisions.id
    RETURNING *;
  SQL
  res = ActiveRecord::Base.connection.execute update_query
  puts "#{res.cmd_tuples} rows linked to EC SRG meetings"
end
