class Species::ShowTaxonConceptSerializer < ActiveModel::Serializer
  root 'taxon_concept'
  attributes :id, :full_name, :author_year, :standard_references

  has_many :common_names, :serializer => Species::CommonNameSerializer
  has_many :synonyms, :serializer => Species::SynonymSerializer
  has_one :m_taxon_concept, :serializer => Species::MTaxonConceptSerializer
  has_many :distributions, :serializer => Species::DistributionSerializer
  has_many :taxon_concept_references, :serializer => Species::ReferenceSerializer,
    :key => :references

end

