# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
class Species::SearchParams < Hash
  include SearchParamSanitiser

  def initialize(params)
    sanitized_params = {
      # possible taxonomies are cms and cites_eu
      taxonomy: whitelist_param(
        sanitise_symbol(params[:taxonomy]),
        [:cites_eu, :cms],
        :cites_eu
      ),
      # possible geo_entity_scope values are: cites, eu, occurrences
      geo_entity_scope: whitelist_param(
        sanitise_symbol(params[:geo_entity_scope]),
        [:cites, :eu, :cms],
        :cites
      ),
      # filtering options
      taxon_concept_query: sanitise_upcase_string(params[:taxon_concept_query]),
      geo_entities: sanitise_integer_array(params[:geo_entities_ids]),
      higher_taxa_ids: sanitise_integer_array(params[:higher_taxa_ids]),
      ranks: whitelist_param_array(
        sanitise_upcase_string_array(params[:ranks]),
        Rank.dict,
        [Rank::SPECIES, Rank::SUBSPECIES]
      ),
      visibility: whitelist_param(
        sanitise_symbol(params[:visibility]),
        [:speciesplus, :trade, :trade_internal, :elibrary],
        :speciesplus
      ),
      include_synonyms: sanitise_boolean(params[:include_synonyms], false),
      page: sanitise_positive_integer(params[:page], 1),
      per_page: sanitise_positive_integer(params[:per_page], 25)
    }

    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

end
