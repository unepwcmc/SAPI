class CreateTaxonConceptsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW taxon_concepts_view AS
      SELECT id, 
      data->'full_name' AS full_name,
      data->'rank_name' AS rank_name,
      data->'kingdom_name' AS kingdom_name,
      data->'taxonomic_position' AS taxonomic_position,
      listing->'cites_listed' AS cites_listed,
      listing->'cites_I' AS cites_I,
      listing->'cites_II' AS cites_II,
      listing->'cites_III' AS cites_III,
      listing->'cites_del' AS cites_del,
      common_names.*,
      synonyms.*
      FROM taxon_concepts
      LEFT JOIN (
        SELECT *
        FROM
        CROSSTAB(
          'SELECT taxon_concepts.id AS taxon_concept_id_com,
          SUBSTRING(languages.name FROM 1 FOR 1) AS lng,
          ARRAY_AGG(common_names.name ORDER BY common_names.id) AS common_names_ary 
          FROM "taxon_concepts"
          INNER JOIN "taxon_commons"
            ON "taxon_commons"."taxon_concept_id" = "taxon_concepts"."id" 
          INNER JOIN "common_names"
            ON "common_names"."id" = "taxon_commons"."common_name_id" 
          INNER JOIN "languages"
            ON "languages"."id" = "common_names"."language_id"
          GROUP BY taxon_concepts.id, SUBSTRING(languages.name FROM 1 FOR 1)
          ORDER BY 1,2'
        ) AS ct(
          taxon_concept_id_com INTEGER,
          lng_E VARCHAR[], lng_F VARCHAR[], lng_S VARCHAR[]
        )
      ) common_names ON taxon_concepts.id = common_names.taxon_concept_id_com
      LEFT JOIN (
        SELECT taxon_concepts.id AS taxon_concept_id_syn, ARRAY_AGG(synonym_tc.data->'full_name') AS synonyms_ary
        FROM taxon_concepts
        LEFT JOIN taxon_relationships
          ON "taxon_relationships"."taxon_concept_id" = "taxon_concepts"."id"
        LEFT JOIN "taxon_relationship_types"
          ON "taxon_relationship_types"."id" = "taxon_relationships"."taxon_relationship_type_id"
        LEFT JOIN taxon_concepts AS synonym_tc
          ON synonym_tc.id = taxon_relationships.other_taxon_concept_id
        GROUP BY taxon_concepts.id
      ) synonyms ON taxon_concepts.id = synonyms.taxon_concept_id_syn
    SQL
  end

  def down
    execute 'DROP VIEW taxon_concepts_view'
  end
end
