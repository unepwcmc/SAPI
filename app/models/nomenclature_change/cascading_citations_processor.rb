class NomenclatureChange::CascadingCitationsProcessor

  def initialize(input, outputs)
    @input = input
    @outputs = outputs
  end

  def run
    @outputs.each do |output|
      @taxon_concept = output.new_taxon_concept || output.taxon_concept
      next unless @taxon_concept
      descendents_for_citation_cascading(@taxon_concept).each do |d|
        Rails.logger.debug("Processing citation for descendant #{d.full_name} of input #{@taxon_concept.full_name}")
        cascade_document_citations(d, @input)
      end
    end
  end

  def summary
    []
  end

  private

  def descendents_for_citation_cascading(taxon_concept)
    unless [Rank::GENUS, Rank::SPECIES].include? taxon_concept.rank.try(:name)
      return []
    end
    # if it is a genus or a species, we want taxon-level nomenclature notes,
    # both public and private, to cascade to descendents
    subquery = <<-SQL
      WITH RECURSIVE descendents AS (
        SELECT id,
          full_name,
          name_status
        FROM taxon_concepts
        WHERE parent_id = :taxon_concept_id
        UNION ALL
        SELECT taxon_concepts.id,
          taxon_concepts.full_name,
          taxon_concepts.name_status
        FROM taxon_concepts
        JOIN descendents h ON h.id = taxon_concepts.parent_id
      )
      SELECT * FROM descendents
    SQL
    sanitized_subquery = ActiveRecord::Base.send(
      :sanitize_sql_array, [subquery, taxon_concept_id: taxon_concept.id]
    )
    TaxonConcept.from(
      "(#{sanitized_subquery}) taxon_concepts"
    )
  end

  def cascade_document_citations(tc, input)
    document_citations = input.document_citation_reassignments.map(&:reassignable)
    document_citations.each do |dc|
      dc.document_citation_taxon_concepts <<
        DocumentCitationTaxonConcept.new(document_citation_id: dc.id, taxon_concept_id: tc.id)
    end
  end

end
