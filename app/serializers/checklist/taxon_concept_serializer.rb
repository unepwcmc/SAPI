class Checklist::TaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :rank_name, :cites_accepted,
    :species_name, :genus_name, :family_name, :order_name,
    :class_name, :phylum_name, :kingdom_name, :hash_ann_symbol,
    :countries_ids, :ancestors_path, :recently_changed,
    :current_parties_ids, :current_listing,
    :author_year, :english_names, :spanish_names, :french_names,
    :synonyms_with_authors, :synonyms

  def include_author_year?
    @options[:authors]
  end

  def include_english_names?
    @options[:english_names]
  end

  def include_spanish_names?
    @options[:spanish_names]
  end

  def include_french_names?
    @options[:french_names]
  end

  def include_synonyms_with_authors?
    @options[:synonyms] && @options[:authors]
  end

  def include_synonyms
    @options[:synonyms] && !@options[:authors]
  end

  has_many :current_additions, :each_serializer => Checklist::ListingChangeSerializer

  def ancestors_path
    # Rank.where(
    #   ["taxonomic_position < ?", taxon_concept.rank.taxonomic_position]
    #   ).order(:taxonomic_position).map do |r|
    #   name = taxon_concept.send "#{r.name.downcase}_name"
    #   id = taxon_concept.send "#{r.name.downcase}_id"
    #   if name && id
    #     link_to(name, params.merge(:taxon_concept_id => id), :title => r.name)
    #   else
    #     nil
    #   end
    # end.compact.join(' > ').html_safe
    '???'
  end

end


  # def taxon_concepts_json_options
  #   json_options = {
  #     :only => [
  #       :id, :full_name, :rank_name, :cites_accepted,
  #       :species_name, :genus_name, :family_name, :order_name,
  #       :class_name, :phylum_name, :kingdom_name, :hash_ann_symbol
  #     ],
  #     :methods => [:countries_ids, :ancestors_path, :recently_changed,
  #       :current_parties_ids, :current_listing]
  #   }

  #   json_options[:only] << :author_year if @authors
  #   json_options[:methods] << :english_names if @english_common_names
  #   json_options[:methods] << :spanish_names if @spanish_common_names
  #   json_options[:methods] << :french_names if @french_common_names
  #   if @synonyms && @authors
  #     json_options[:methods] << :synonyms_with_authors
  #   elsif @synonyms
  #     json_options[:methods] << :synonyms
  #   end
  #   json_options
  # end

  # def listing_changes_json_options
  #   json_options = {
  #     :only => [:id, :change_type_name, :species_listing_name,
  #       :party_id, :is_current, :hash_ann_symbol, :auto_note,
  #       :short_note_en, :full_note_en, :hash_full_note_en,
  #       :inherited_short_note_en, :inherited_full_note_en],
  #     :methods => [:countries_ids, :effective_at_formatted]
  #   }
  #   json_options
  # end

  # def json_options
  #   json_options = taxon_concepts_json_options
  #   json_options[:include] = {
  #     :current_additions => listing_changes_json_options
  #   }
  #   json_options
  # end