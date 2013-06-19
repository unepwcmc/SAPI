class Checklist::Json::History < Checklist::History
  include Checklist::Json::Document
  include Checklist::Json::HistoryContent

  def initialize(options)
    super(options)
    @json_options = json_options
  end

  def taxon_concepts_json_options
    json_options = {
      :only => [
        :id, :kingdom_name, :phylum_name, :class_name, :order_name,
        :family_name, :genus_name, :species_name, :subspecies_name,
        :full_name, :author_year, :rank_name
      ]
    }
    json_options
  end

  def listing_changes_json_options
    json_options = {
      :only => [
        :species_listing_name, :party_iso_code,
        :change_type_name, :is_current,
        :hash_ann_symbol, :hash_full_note_en,
        :full_note_en, :short_note_en, :short_note_es, :short_note_fr
      ],
      :methods => [:party_full_name,  :effective_at_formatted]
    }
    json_options
  end

end
