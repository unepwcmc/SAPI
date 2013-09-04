class Checklist::HistoryTaxonConceptSerializer < ActiveModel::Serializer
  attributes :id,
    :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
    :genus_name, :species_name, :subspecies_name,
    :full_name, :author_year, :rank_name

  has_many :historic_cites_listing_changes_for_downloads,
    :key => :listing_changes,
    :serializer => Checklist::HistoryListingChangeSerializer

  def include_author_year?
    @options[:authors]
  end

end
