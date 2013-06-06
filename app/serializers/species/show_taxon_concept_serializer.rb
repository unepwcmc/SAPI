class Species::ShowTaxonConceptSerializer < ActiveModel::Serializer
  root 'taxon_concept'
  attributes :id, :full_name, :author_year, :rank_name,
    :family_id, :family_name, :order_id, :order_name,
    :phylum_id, :phylum_name, :class_id, :class_name,
    :author_year, :common_names, :synonyms

  def common_names
    object.common_names.map do |cm|
      {
        :name => cm.name,
        :language => cm.language.name,
        :iso_code3 => cm.language.iso_code3
      }
    end
  end

  def synonyms
    object.taxon_concept.synonyms.map do |s|
      {
        :name => s.full_name,
        :author => s.author_year
      }
    end
  end
end

