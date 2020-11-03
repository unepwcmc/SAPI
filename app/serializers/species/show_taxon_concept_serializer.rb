class Species::ShowTaxonConceptSerializer < ActiveModel::Serializer
  cached
  root 'taxon_concept'
  attributes :id, :parent_id, :full_name, :author_year, :standard_references,
    :common_names, :distributions, :subspecies, :distribution_references,
    :taxonomy, :kingdom_name, :phylum_name, :order_name, :class_name, :family_name,
    :genus_name, :species_name, :rank_name, :name_status, :nomenclature_note_en, :nomenclature_notification

  has_many :synonyms, :serializer => Species::SynonymSerializer
  has_many :taxon_concept_references, :serializer => Species::ReferenceSerializer,
    :key => :references

  def rank_name
    object.data['rank_name']
  end

  def kingdom_name
    object.data['kingdom_name']
  end

  def phylum_name
    object.data['phylum_name']
  end

  def class_name
    object.data['class_name']
  end

  def order_name
    object.data['order_name']
  end

  def family_name
    object.data['family_name']
  end

  def genus_name
    object.data['genus_name']
  end

  def species_name
    object.data['species_name']
  end

  def taxonomy
    object.taxonomy.name.downcase
  end

  def synonyms
    object.synonyms.
      order("full_name")
  end

  def object_and_children
    [object.id] + object.children.pluck(:id)
  end

  def ancestors
    [
      object.data['kingdom_id'], object.data['phylum_id'],
      object.data['order_id'], object.data['class_id'],
      object.data['family_id'], object.data['subfamily_id'],
      object.data['genus_id']
    ].compact
  end

  def common_names
    CommonName.from('api_common_names_view common_names').
      where(taxon_concept_id: object.id).
      select("language_name_en AS lang").
      select("string_agg(name, ', ') AS names").
      select(<<-SQL
          CASE
            WHEN UPPER(language_name_en) = 'ENGLISH' OR
              UPPER(language_name_en) = 'FRENCH' OR
              UPPER(language_name_en) = 'SPANISH'
              THEN true
            ELSE false
          END AS convention_language
        SQL
      ).
      group("language_name_en").order("language_name_en").all
  end

  def distributions_with_tags_and_references
    Distribution.from('api_distributions_view distributions').
      where(taxon_concept_id: object.id).
      select("name_en AS name, name_en AS country, ARRAY_TO_STRING(tags,  ',') AS tags_list, ARRAY_TO_STRING(citations, '; ') AS country_references").
      order('name_en').all
  end

  def distributions
    distributions_with_tags_and_references
  end

  def subspecies
    MTaxonConcept.where(:parent_id => object.id).
      where("name_status NOT IN ('S', 'T', 'N')").
      select([:full_name, :author_year, :id, :show_in_species_plus]).
      order(:full_name).all
  end

  def standard_references
    object.standard_taxon_concept_references
  end

  def distribution_references
    distributions_with_tags_and_references
  end

  def cache_key
    key = [
      self.class.name,
      self.id,
      object.updated_at,
      object.dependents_updated_at,
      object.m_taxon_concept.try(:updated_at) || "",
      scope.current_user ? true : false
    ]
    Rails.logger.debug "CACHE KEY: #{key.inspect}"
    key
  end

  def nomenclature_notification
    outputs = NomenclatureChange::Output.includes("nomenclature_change").where(
      "
        (taxon_concept_id = ? OR new_taxon_concept_id = ?) AND
        nomenclature_changes.created_at > ? AND nomenclature_changes.status = 'submitted'
        AND nomenclature_changes.created_at < ?
      ",
      object.id, object.id, 6.months.ago, Date.new(2017, 8, 1)
    )

    outputs.present?
  end
end
