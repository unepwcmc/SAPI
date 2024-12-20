class TimestampViewDefinitions < ActiveRecord::Migration[4.2]
  def change
    execute function_sql('20141223141125', 'array_agg_not_null')
    execute function_sql('20141223141125', 'strip_tags')
    execute 'DROP VIEW IF EXISTS common_names_view'
    execute "CREATE VIEW common_names_view AS #{view_sql('20141223141125', 'common_names_view')}"
    execute 'DROP VIEW IF EXISTS documents_view'
    execute "CREATE VIEW documents_view AS #{view_sql('20141223141125', 'documents_view')}"
    execute 'DROP VIEW IF EXISTS eu_decisions_view'
    execute "CREATE VIEW eu_decisions_view AS #{view_sql('20141223141125', 'eu_decisions_view')}"
    execute 'DROP VIEW IF EXISTS eu_regulations_applicability_view'
    execute "CREATE VIEW eu_regulations_applicability_view AS #{view_sql('20141223141125', 'eu_regulations_applicability_view')}"
    execute 'DROP VIEW IF EXISTS orphaned_taxon_concepts_view'
    execute "CREATE VIEW orphaned_taxon_concepts_view AS #{view_sql('20141223141125', 'orphaned_taxon_concepts_view')}"
    execute 'DROP VIEW IF EXISTS species_reference_output_view'
    execute "CREATE VIEW species_reference_output_view AS #{view_sql('20141223141125', 'species_reference_output_view')}"
    execute 'DROP VIEW IF EXISTS standard_reference_output_view'
    execute "CREATE VIEW standard_reference_output_view AS #{view_sql('20141223141125', 'standard_reference_output_view')}"
    execute 'DROP VIEW IF EXISTS synonyms_and_trade_names_view'
    execute "CREATE VIEW synonyms_and_trade_names_view AS #{view_sql('20141223141125', 'synonyms_and_trade_names_view')}"
    execute 'DROP VIEW IF EXISTS taxon_concepts_distributions_view'
    execute "CREATE VIEW taxon_concepts_distributions_view AS #{view_sql('20141223141125', 'taxon_concepts_distributions_view')}"
    execute 'DROP VIEW IF EXISTS taxon_concepts_names_view'
    execute "CREATE VIEW taxon_concepts_names_view AS #{view_sql('20141223141125', 'taxon_concepts_names_view')}"
    execute 'DROP VIEW IF EXISTS trade_shipments_with_taxa_view'
    execute "CREATE VIEW trade_shipments_with_taxa_view AS #{view_sql('20141223141125', 'trade_shipments_with_taxa_view')}"
    execute 'DROP VIEW IF EXISTS valid_appendix_view'
    execute "CREATE VIEW valid_appendix_view AS #{view_sql('20141223141125', 'valid_appendix_view')}"
    execute 'DROP VIEW IF EXISTS valid_country_of_origin_view'
    execute "CREATE VIEW valid_country_of_origin_view AS #{view_sql('20141223141125', 'valid_country_of_origin_view')}"
    execute 'DROP VIEW IF EXISTS valid_taxon_concept_country_of_origin_view'
    execute "CREATE VIEW valid_taxon_concept_country_of_origin_view AS #{view_sql('20141223141125', 'valid_taxon_concept_country_of_origin_view')}"
    execute 'DROP VIEW IF EXISTS valid_taxon_concept_exporter_view'
    execute "CREATE VIEW valid_taxon_concept_exporter_view AS #{view_sql('20141223141125', 'valid_taxon_concept_exporter_view')}"
    execute 'DROP VIEW IF EXISTS valid_taxon_concept_country_view' # obsolete view
    execute 'DROP VIEW IF EXISTS valid_taxon_concept_term_view'
    execute "CREATE VIEW valid_taxon_concept_term_view AS #{view_sql('20141223141125', 'valid_taxon_concept_term_view')}"
    execute 'DROP VIEW IF EXISTS valid_taxon_name_view'
    execute "CREATE VIEW valid_taxon_name_view AS #{view_sql('20141223141125', 'valid_taxon_name_view')}"
    execute 'DROP VIEW IF EXISTS valid_term_purpose_view'
    execute "CREATE VIEW valid_term_purpose_view AS #{view_sql('20141223141125', 'valid_term_purpose_view')}"
    execute 'DROP VIEW IF EXISTS valid_term_unit_view'
    execute "CREATE VIEW valid_term_unit_view AS #{view_sql('20141223141125', 'valid_term_unit_view')}"
    execute 'DROP VIEW IF EXISTS valid_purpose_code_view'
    execute "CREATE VIEW valid_purpose_code_view AS #{view_sql('20141223141125', 'valid_purpose_code_view')}"
    execute 'DROP VIEW IF EXISTS valid_source_code_view'
    execute "CREATE VIEW valid_source_code_view AS #{view_sql('20141223141125', 'valid_source_code_view')}"
    execute 'DROP VIEW IF EXISTS valid_term_code_view'
    execute "CREATE VIEW valid_term_code_view AS #{view_sql('20141223141125', 'valid_term_code_view')}"
    execute 'DROP VIEW IF EXISTS valid_unit_code_view'
    execute "CREATE VIEW valid_unit_code_view AS #{view_sql('20141223141125', 'valid_unit_code_view')}"
    execute 'DROP VIEW IF EXISTS valid_trading_partner_view'
    execute "CREATE VIEW valid_trading_partner_view AS #{view_sql('20141223141125', 'valid_trading_partner_view')}"
    execute 'DROP VIEW IF EXISTS year_annual_reports_by_countries'
    execute "CREATE VIEW year_annual_reports_by_countries AS #{view_sql('20141223141125', 'year_annual_reports_by_countries')}"
  end
end
