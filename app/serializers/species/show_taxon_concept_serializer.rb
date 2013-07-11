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
  has_many :cites_listing_changes, :serializer => Species::CitesListingChangeSerializer,
    :key => :cites_listings
  has_many :eu_listing_changes, :serializer => Species::EuListingChangeSerializer,
    :key => :eu_listings


  def quotas
    object.quotas.joins(:geo_entity).
      includes([:unit, :geo_entity]).
      order("geo_entities.name_en ASC, trade_restrictions.notes ASC")
  end

  def cites_suspensions
    object.cites_suspensions.
      joins([:start_notification, :geo_entity]).
      order("is_current DESC, events.effective_at DESC, geo_entities.name_en ASC")
  end

  def cites_listing_changes
    cites = Designation.find_by_name(Designation::CITES)
    MListingChange.
      where(:taxon_concept_id => object.id, :show_in_history => true, :designation_id => cites && cites.id).
      order("is_current DESC").
      order(<<-SQL
          effective_at DESC,
          CASE
            WHEN change_type_name = 'ADDITION' THEN 3
            WHEN change_type_name = 'RESERVATION' THEN 2
            WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 1
            WHEN change_type_name = 'DELETION' THEN 0
          END
        SQL
      )
  end

  def eu_listing_changes
    eu = Designation.find_by_name(Designation::EU)
    MListingChange.
      where(:taxon_concept_id => object.id, :show_in_history => true, :designation_id => eu && eu.id).
      includes(:event).
      order("is_current DESC").
      order(<<-SQL
        effective_at DESC,
        CASE
          WHEN change_type_name = 'ADDITION' THEN 3
          WHEN change_type_name = 'RESERVATION' THEN 2
          WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 1
          WHEN change_type_name = 'DELETION' THEN 0
        END
        SQL
      )
  end

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

