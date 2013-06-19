class Species::ShowTaxonConceptSerializer < ActiveModel::Serializer
  root 'taxon_concept'
  attributes :id, :full_name, :author_year, :standard_references,
    :common_names, :distributions

  has_many :synonyms, :serializer => Species::SynonymSerializer
  has_one :m_taxon_concept, :serializer => Species::MTaxonConceptSerializer
  has_many :taxon_concept_references, :serializer => Species::ReferenceSerializer,
    :key => :references
  has_many :quotas, :serializer => Species::QuotaSerializer
  has_many :cites_suspensions, :serializer => Species::CitesSuspensionSerializer
  #has_many :listing_changes, :serializer => Species::CitesListingChangeSerializer

  def common_names
    object.common_names.joins(:language).
      select("languages.name_en AS lang").
      select("string_agg(common_names.name, ', ') AS names").
      group("languages.name_en").order("languages.name_en")
  end

  def distributions
    a = object.distributions.joins(:geo_entity).
      select('geo_entities.name_en AS name_en').
      joins("LEFT JOIN taggings ON
        taggings.taggable_id = distributions.id
        AND taggings.taggable_type = 'Distribution'
        LEFT JOIN tags ON tags.id = taggings.tag_id").
      select("string_agg(tags.name, ', ') AS tags_list").
      group('geo_entities.name_en').
      order('geo_entities.name_en')
  end
end

