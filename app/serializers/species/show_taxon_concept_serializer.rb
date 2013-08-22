class Species::ShowTaxonConceptSerializer < ActiveModel::Serializer
  cached
  root 'taxon_concept'
  attributes :id, :full_name, :author_year, :standard_references,
    :common_names, :distributions, :subspecies, :distribution_references,
    :taxonomy

  has_many :synonyms, :serializer => Species::SynonymSerializer
  has_one :m_taxon_concept, :serializer => Species::MTaxonConceptSerializer
  has_many :taxon_concept_references, :serializer => Species::ReferenceSerializer,
    :key => :references
  def taxonomy
    object.taxonomy.name.downcase
  end

  def synonyms
    object.synonyms.
      order("full_name")
  end

  def object_and_children
    [object.id]+object.children.select(:id).map(&:id)
  end

  def children_and_ancestors
    m_concept = object.m_taxon_concept
    ids = object.children.select(:id).map(&:id)+
            [m_concept.kingdom_id, m_concept.phylum_id,
              m_concept.order_id, m_concept.class_id,
              m_concept.family_id, m_concept.subfamily_id,
              m_concept.genus_id]
    ids.reject{|r| r.nil?} #remove nils
  end

  def object_children_and_ancestors
    [object.id]+children_and_ancestors
  end

  def common_names
    object.common_names.joins(:language).
      select("languages.name_en AS lang").
      select("string_agg(common_names.name, ', ') AS names").
      select(<<-SQL
          CASE
            WHEN UPPER(languages.name_en) = 'ENGLISH' OR
              UPPER(languages.name_en) = 'FRENCH' OR
              UPPER(languages.name_en) = 'SPANISH'
              THEN true
            ELSE false
          END AS convention_language
        SQL
      ).
      group("languages.name_en").order("languages.name_en")
  end

  def distributions
    object.distributions.joins(:geo_entity).
      select('geo_entities.name_en AS name_en').
      joins("LEFT JOIN taggings ON
        taggings.taggable_id = distributions.id
        AND taggings.taggable_type = 'Distribution'
        LEFT JOIN tags ON tags.id = taggings.tag_id").
      select("string_agg(tags.name, ', ') AS tags_list").
      group('geo_entities.name_en').
      order('geo_entities.name_en')
  end

  def subspecies
    TaxonConcept.where(:parent_id => object.id).
      select([:full_name, :author_year]).
      order(:full_name)
  end

  def distribution_references
    object.distributions.joins(:geo_entity).
      joins(:distribution_references => :reference).
      select("geo_entities.name_en AS country").
      select("string_agg(\"references\".citation, '; ') AS country_references").
      group('geo_entities.name_en').
      order('geo_entities.name_en')
  end

  def cached_key
    [object]
  end
end

