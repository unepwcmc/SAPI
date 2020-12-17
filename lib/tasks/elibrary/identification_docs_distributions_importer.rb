class Elibrary::IdentificationDocsDistributionsImporter

  def self.run
    puts "Importing distributions at species level..."
    import_species_distributions
    puts "Importing distributions at higher taxa level..."
    import_higher_taxa_distributions
    puts "Managing exceptions"
    exceptions
    puts "Refresh materialized views"
    DocumentSearch.refresh_citations_and_documents
  end

  private

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

      ON CONFLICT (geo_entity_id, document_citation_id) DO NOTHING

    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  # import distribution on material documents tagged at level higher than species
  def self.import_higher_taxa_distributions

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
          .compact.flatten.uniq.sort

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

  EXCEPTIONS = [
    { manual_id: "Commercial species of freshwater stingrays in Brazil_EN.pdf", geo_entity: 'Brazil' },
    { manual_id: "Guide d'identification Des espèces du Tchad CITES_FR.pdf", geo_entity: 'Chad' },
    { manual_id: "Identification Manual for the Conservation of Turtles in China_EN.pdf", geo_entity: 'China' },
    { manual_id: "Guía para la identificación de especies de tiburones, rayas y quimeras de Colombia_ES.pdf", geo_entity: 'Colombia' },
    { manual_id: "Guide d'identification Des espèces du Gabon CITES_FR.pdf", geo_entity: 'Gabon' },
    { manual_id: "Guía de identificación para aves silvestres de mayor comercio en México_ES.pdf", geo_entity: 'Mexico' },
    { manual_id: "Guía de identificación para mamíferos silvestres de mayor comercio en México_ES.pdf", geo_entity: 'Mexico' },
    { manual_id: "http://biodiversityadvisor.sanbi.org/species-id-tool/", geo_entity: 'South Africa' }
  ].freeze
  def self.exceptions
    EXCEPTIONS.each do |exception|
      doc = Document.where(manual_id: exception[:manual_id]).first
      doc_cit_id = DocumentCitation.where(document_id: doc.id).first.id
      DocumentCitationGeoEntity.where(document_citation_id: doc_cit_id).destroy_all
      geo_id = GeoEntity.find_by_name_en(exception[:geo_entity]).id
      DocumentCitationGeoEntity.create!(document_citation_id: doc_cit_id, geo_entity_id: geo_id)
    end
  end
end
