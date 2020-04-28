class Elibrary::IdentificationDocsDistributionsImporter
  # import distribution on material documents tagged at species level
  def self.import_species_distributions
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
  end

  # import distribution on material documents tagged at level higher than species
  def self.import_higer_taxa_distributions

    sql = <<-SQL
    WITH doc_taxon_tmp AS (
      SELECT DISTINCT(dc.id) doc_cit_id, UNNEST(d.taxon_concept_ids)tc_ids
      FROM document_citation_taxon_concepts dctc
      JOIN document_citations dc ON dc.id = dctc.document_citation_id
      JOIN api_documents_mview d ON d.id = dc.document_id
      WHERE d.document_type IN ('Document::IdManual', 'Document::VirtualCollege')
    )
    SELECT tmp.*
    FROM doc_taxon_tmp tmp
    LEFT OUTER JOIN taxon_concepts_mview tc ON tmp.tc_ids=tc.id
    WHERE tc.countries_ids_ary IS NULL
    SQL

    results = ActiveRecord::Base.connection.execute(sql)

    results.to_a.each_slice(50) do |result|
      sql, no_distr = [], []
      result.each do |res|
        doc_cit_id = res['doc_cit_id']

        children = MTaxonConcept.descendants_ids(res['tc_ids'])

        countries_ids = MTaxonConcept.where(id: children).pluck(:countries_ids_ary)
                                     .compact.map{ |country| country.gsub(/[{}]/, '').split(',').map(&:to_i)}
                                     .flatten.uniq.sort

        if countries_ids.empty?
          no_distr << [doc_cit_id, children]
          next
        end

        sql << "SELECT #{doc_cit_id} document_citation_id, geo_entity_id
                FROM UNNEST(ARRAY#{countries_ids}) geo_entity_id"
      end

      query = <<-SQL
       WITH doc_cit_country_tmp AS (
         #{sql.join("\n\nUNION\n\n")}
       )
       INSERT INTO "document_citation_geo_entities" (
         document_citation_id,
         geo_entity_id,
         created_at,
         updated_at
       )
       SELECT
        doc_cit_country_tmp.*,
        NOW(),
        NOW()
       FROM doc_cit_country_tmp

       ON CONFLICT (geo_entity_id, document_citation_id) DO NOTHING

      SQL
      ActiveRecord::Base.connection.execute(query)
    end
  end
end
