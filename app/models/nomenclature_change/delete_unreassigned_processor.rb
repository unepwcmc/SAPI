class NomenclatureChange::DeleteUnreassignedProcessor

  def initialize(input)
    @input = input
  end

  def run
    process_unreassigned_distributions
    process_unreassigned_taxon_concept_citations
    process_unreassigned_names
  end

  def process_unreassigned_distributions
    distributions = @input.distribution_reassignments.map { |dr|
      dr.reassignable if _is_input_reassignment(dr)
    }.compact

    @input.taxon_concept.distributions.each do |distribution|
      unless distributions.map { |dr| dr.id }.include?(distribution.id)
        distribution.destroy
      end
    end
  end

  # ACHTUNG! the reassigned object is a citation, but the destroyed object
  # is a taxon concept citation!
  def process_unreassigned_taxon_concept_citations
    citations = @input.document_citation_reassignments.map { |c|
      c.reassignable if _is_input_reassignment(c)
    }.compact

    @input.taxon_concept.document_citation_taxon_concepts.each do |tc_citation|
      citation = tc_citation.document_citation
      unless citations.map { |c| c.id }.include?(citation.id)
        tc_citation.destroy
        # if no other taxa were attached to this citation, get rid of it
        unless citation.document_citation_taxon_concepts.any?
          citation.destroy
        end
      end
    end
  end

  def process_unreassigned_names
    names = @input.name_reassignments.map { |nr|
      nr.reassignable if _is_input_reassignment(nr)
    }.compact

    @input.taxon_concept.taxon_relationships.each do |taxon_relationship|
      unless names.map { |nr| nr.id }.include?(taxon_relationship.id)
        taxon_relationship.destroy
      end
    end
  end

  def _is_input_reassignment(reassignment)
    reassignment.reassignment_targets.any? do |t|
      t.output.taxon_concept_id == @input.taxon_concept_id
    end
  end

  def summary
    []
  end

end
