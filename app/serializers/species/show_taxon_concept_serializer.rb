class Species::ShowTaxonConceptSerializer < ActiveModel::Serializer
  cached
  root 'taxon_concept'
  attributes :id, :full_name, :author_year, :standard_references,
    :common_names, :distributions, :subspecies, :distribution_references,
    :taxonomy, :kingdom_name, :phylum_name, :order_name, :class_name, :family_name,
    :genus_name, :species_name

  has_many :synonyms, :serializer => Species::SynonymSerializer
  has_many :taxon_concept_references, :serializer => Species::ReferenceSerializer,
    :key => :references


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
    [object.id]+object.children.select(:id).map(&:id)
  end

  def children_and_ancestors
    ids = object.children.select(:id).map(&:id)+
            [object.data['kingdom_id'], object.data['phylum_id'],
              object.data['order_id'], object.data['class_id'],
              object.data['family_id'], object.data['subfamily_id'],
              object.data['genus_id']]
    ids.reject{|r| r.nil?} #remove nils
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
      group("languages.name_en").order("languages.name_en").all
  end

  def distributions
    object.distributions.joins(:geo_entity).
      select('geo_entities.name_en AS name').
      joins("LEFT JOIN taggings ON
        taggings.taggable_id = distributions.id
        AND taggings.taggable_type = 'Distribution'
        LEFT JOIN tags ON tags.id = taggings.tag_id").
      select("string_agg(tags.name, ', ') AS tags_list").
      group('geo_entities.name_en').
      order('geo_entities.name_en').all
  end

  def subspecies
    TaxonConcept.where(:parent_id => object.id).
      select([:full_name, :author_year]).
      order(:full_name).all
  end

  def distribution_references
    object.distributions.joins(:geo_entity).
      joins(:distribution_references => :reference).
      select("geo_entities.name_en AS country").
      select("string_agg(\"references\".citation, '; ') AS country_references").
      group('geo_entities.name_en').
      order('geo_entities.name_en').all
  end

  def cache_key  
    key = [
      self.class.name,
      self.id,
      object.updated_at,
      object.m_taxon_concept.try(:updated_at) || ""
    ]
    Rails.logger.debug "CACHE KEY: #{key.inspect}"
    key
  end
end

