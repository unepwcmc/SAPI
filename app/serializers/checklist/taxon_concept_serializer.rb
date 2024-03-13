class Checklist::TaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :rank_name, :cites_accepted,
    :subspecies_name, :species_name, :genus_name, :family_name, :order_name,
    :class_name, :phylum_name, :kingdom_name, :hash_ann_symbol,
    :countries_ids, :ancestors_path, :recently_changed,
    :current_parties_ids, :current_listing,
    :author_year, :english_names, :spanish_names, :french_names,
    :synonyms_with_authors, :synonyms, :ancestors_ids, :ancestors_path, :item_type

  has_many :current_cites_additions, :serializer => Checklist::ListingChangeSerializer,
    :key => :current_additions

  def id
    if object.is_a? Checklist::HigherTaxaItem
      object.id + 1000000 # unless ids differ, Ember will create a single object
    else
      object.id
    end
  end

  def item_type
    return 'HigherTaxa' if object.is_a? Checklist::HigherTaxaItem
    'TaxonConcept'
  end

  def include_author_year?
    @options[:authors]
  end

  def include_english_names?
    @options[:english_names]
  end

  def include_spanish_names?
    @options[:spanish_names]
  end

  def include_french_names?
    @options[:french_names]
  end

  def include_synonyms_with_authors?
    @options[:synonyms] && @options[:authors]
  end

  def include_synonyms?
    @options[:synonyms] && !@options[:authors]
  end

  def include_ancestors_ids?
    object.is_a? Checklist::HigherTaxaItem
  end

  def include_ancestors_path?
    object.is_a? Checklist::HigherTaxaItem
  end

  # Override the matview here to instead query the db for non-extinct distributions
  #
  # These are defined as:
  # - Distributions which are untagged
  # - Distributions which have any tags other than extinct
  #
  # i.e. not distributions which have only a single tag, "extinct"
  #
  # A good example is Hippopus hippopus, which has:
  #
  # - American Samoa (145): extinct, reintroduced
  # - Australia (113): (not tagged)
  # - Cook Islands (242): introduced
  # - Fiji (158): reintroduced, extinct
  # - Guam (254): extinct
  # - ...others
  #
  # Of those listed above, Guam and only Guam should be excluded.
  def countries_ids
    if object.countries_ids.length == 0
      return object.countries_ids
    end

    non_extinct_distributions = Distribution.joins("
      LEFT JOIN (
        SELECT taggings.taggable_id, array_agg(tags.name) AS tag_names
        FROM taggings
        JOIN tags ON taggings.tag_id = tags.id
        WHERE taggings.taggable_type = 'Distribution'
        GROUP BY taggings.taggable_id
      ) d_t ON
        d_t.taggable_id = distributions.id AND
        d_t.tag_names = '{extinct}'::VARCHAR[]
    ").where({
      taxon_concept_id: object.id,
      'd_t.taggable_id': nil
    })

    # We can't just return the ids, we need to retain the order of the original
    # array, which is sorted on English name.
    country_id_not_extinct = (
      non_extinct_distributions.map do |distribution|
        [ distribution.geo_entity_id, true ]
      end
    ).to_h

    object.countries_ids.select do |country_id|
      country_id_not_extinct[country_id]
    end
  end
end
