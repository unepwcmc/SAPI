class TaxonTree

  def initialize(taxon_concept)
    @taxon_concepts = taxon_concept.self_and_descendants
  end

end