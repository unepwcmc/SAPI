# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
# Array parameters are sorted for caching purposes.
class Species::SearchParams < Hash
  def initialize(params)
    sanitized_params = {
      #possible taxonomies are cms and cites_eu
      :taxonomy =>
        params[:taxonomy] ? params[:taxonomy].to_sym : nil,
      #possible geo_entity_scope values are: cites, eu, occurrences
      :geo_entity_scope =>
        params[:geo_entity_scope] ? params[:geo_entity_scope].to_sym : nil,
      #filtering options
      :taxon_concept_query =>
        params[:taxon_concept_query] ? params[:taxon_concept_query].upcase.strip : nil,
      :geo_entities => params[:geo_entities_ids].blank? ? [] : params[:geo_entities_ids],
      :higher_taxa_ids => params[:higher_taxa_ids] ? params[:higher_taxa_ids] : nil,
      :ranks => params[:ranks] ? 
        Rank.dict & params[:ranks].map(&:upcase) : [Rank::SPECIES]
    }
    unless [:cites_eu, :cms].include? sanitized_params[:taxonomy]
      sanitized_params[:taxonomy] = :cites_eu
    end
    unless [:cites, :eu, :occurrences].include? sanitized_params[:geo_entity_scope]
      sanitized_params[:geo_entity_scope] = :cites
    end
    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

end
