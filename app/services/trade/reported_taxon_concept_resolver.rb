class Trade::ReportedTaxonConceptResolver
  attr_reader :accepted_taxa
  def initialize(reported_taxon_concept_id)
    # automatically resolve accepted taxon name
    reported_taxon = TaxonConcept.find_by_id(reported_taxon_concept_id)
    return [] unless reported_taxon
    @accepted_taxa = reported_taxon &&
      case reported_taxon.name_status
      when 'S'
        reported_taxon.accepted_names
      when 'T'
        reported_taxon.accepted_names_for_trade_name
      else
        [reported_taxon]
      end
  end
end
