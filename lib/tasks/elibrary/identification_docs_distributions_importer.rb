class Elibrary::IdentificationDocsDistributionsImporter
  def self.run
    sql = <<-SQL
      WITH doc_taxon_tmp AS (
  	    SELECT dc.id doc_cit_id, dctc.taxon_concept_id tc_id
  	    FROM document_citation_taxon_concepts dctc
  	    JOIN document_citations dc ON dc.id = dctc.document_citation_id
  	    JOIN api_documents_mview d ON d.id = dc.document_id
  	    WHERE d.document_type IN ('Document::IdManual', 'Document::VirtualCollege')
      )

      INSERT INTO "document_citation_geo_entities" (
        document_citation_id,
        geo_entity_id,
        created_at,
        updated_at
      )

      SELECT
        doc_cit_id,
        UNNEST(ARRAY_AGG(DISTINCT (country_id))) country_id,
        NOW(),
        NOW()
      FROM (
  	     SELECT doc_cit_id, UNNEST(countries_ids_ary)
  	     FROM  doc_taxon_tmp tmp
  	     LEFT OUTER JOIN taxon_concepts_mview tc ON tc_id=tc.id
         ) AS t(doc_cit_id,country_id)
      GROUP BY doc_cit_id
      ORDER BY doc_cit_id DESC;
    SQL

    ActiveRecord::Base.connection.execute(sql)

    sql = <<-SQL
      
    SQL
  end
end
