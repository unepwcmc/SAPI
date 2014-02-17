module MListingChange
  include PgArrayParser

  def self.included(base)
    base.class_eval do
      belongs_to :designation
      belongs_to :taxon_concept, :class_name => 'MTaxonConcept'
      belongs_to :listing_change, :foreign_key => :id
      belongs_to :event
      translates :short_note, :full_note, :hash_full_note,
        :inherited_short_note, :inherited_full_note, :auto_note
    end
  end

  def effective_at_formatted
    effective_at.strftime("%d/%m/%Y")
  end

  def full_hash_ann_symbol
    "#{hash_ann_parent_symbol}#{hash_ann_symbol}"
  end

  def countries_ids
    if respond_to?(:countries_ids_ary) && countries_ids_ary?
      parse_pg_array(countries_ids_ary || '').compact
    elsif respond_to? :lc_countries_ids_ary
      parse_pg_array(lc_countries_ids_ary || '').compact
    else
      []
    end
  end

  def countries_iso_codes
    CountryDictionary.instance.get_iso_codes_by_ids(countries_ids).compact
  end

  def countries_full_names
    CountryDictionary.instance.get_names_by_ids(countries_ids).compact
  end

  def party_full_name
    CountryDictionary.instance.get_name_by_id(party_id)
  end

  def to_timeline_event
    Checklist::TimelineEvent.new(
      self.as_json(
        :only => [
          :id, :change_type_name, :species_listing_name, :party_id,
          :is_current, :hash_ann_symbol, :hash_ann_parent_symbol,
<<<<<<< HEAD
          :effective_at, :inclusion_taxon_concept_id
=======
          :effective_at, :auto_note, :inclusion_taxon_concept_id
>>>>>>> [#65555822] localised short_note and full_note
        ],
        :methods => [
          :countries_ids,
          :short_note, :full_note, :hash_full_note,
<<<<<<< HEAD
          :inherited_short_note, :inherited_full_note, :auto_note
=======
          :inherited_short_note, :inherited_full_note,
>>>>>>> [#65555822] localised short_note and full_note
        ]
      ).symbolize_keys
    )
  end

end
