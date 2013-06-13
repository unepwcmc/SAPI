class Species::ShowTaxonConceptSerializer < ActiveModel::Serializer
  root 'taxon_concept'
  attributes :id, :full_name, :author_year, :standard_references,
    :common_names

  #has_many :common_names, :serializer => Species::CommonNameSerializer
  has_many :synonyms, :serializer => Species::SynonymSerializer
  has_one :m_taxon_concept, :serializer => Species::MTaxonConceptSerializer
  has_many :distributions, :serializer => Species::DistributionSerializer
  has_many :taxon_concept_references, :serializer => Species::ReferenceSerializer,
    :key => :references
  has_many :quotas, :serializer => Species::QuotaSerializer
  has_many :cites_suspensions, :serializer => Species::CitesSuspensionSerializer
  has_many :listing_changes, :serializer => Species::CitesListingChangeSerializer
  
  def common_names
    sql = <<-SQL
      SELECT languages.name_en AS language, string_agg(name, ', ') AS names
      FROM common_names
      INNER JOIN languages ON common_names.language_id = languages.id
      INNER JOIN taxon_commons ON taxon_commons.common_name_id = common_names.id
        AND taxon_commons.taxon_concept_id = #{object.id}
      GROUP BY languages.name_en
    SQL
    ActiveRecord::Base.connection.execute(sql)
    #t.common_names.joins(:language).
    #select("languages.name_en").
    #select("string_agg(common_names.name, ', ')").
    #group("languages.name_en")
  end
end

