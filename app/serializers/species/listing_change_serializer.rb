class Species::ListingChangeSerializer < ActiveModel::Serializer
  attributes :is_current, :species_listing_name, :party_full_name,
   :effective_at_formatted, :short_note_en, :full_note_en, :auto_note,
   :is_inclusion, :subspecies_info, :inherited_full_note_en, :inherited_short_note_en

   def include_is_inclusion?
     return true unless @options[:trimmed]
     @options[:trimmed] == 'false'
   end

   def include_subspecies_info?
     return true unless @options[:trimmed]
     @options[:trimmed] == 'false'
   end

  def is_inclusion
    object.inclusion_taxon_concept_id
  end

  def hash_display
    return "" unless object.hash_ann_parent_symbol.present?
    object.hash_ann_parent_symbol + " " + object.hash_ann_symbol
  end
end
