class Checklist::TimelineEvent
  include ActiveModel::SerializerSupport
  attr_accessor :id, :change_type_name, :species_listing_name, :effective_at,
    :party_id, :is_current, :pos, :auto_note, :short_note, :full_note,
    :hash_full_note, :hash_ann_symbol, :hash_ann_parent_symbol,
    :inherited_short_note, :inherited_full_note, :nomenclature_note
  # options to be passed:
  #:change_type_name
  #:effective_at
  #:is_current
  #:hash_full_note may be rich text (html)
  #:short_note may be rich text (html)
  #:full_note may be rich text (html)
  #:hash_ann_symbol e.g. #4
  #:hash_ann_parent_symbol e.g. CoP15
  #:pos - position (%)
  def initialize(options)
    # if it is an auto-inserted deletion it won't have an id
    id = options[:id] || (
      (options[:species_listing_id] << 16) +
      (options[:change_type_id] << 12) +
      (options[:effective_at].to_i << 8) +
      (options[:party_id] || 0)
    )
    @id = (options[:taxon_concept_id] << 8) + id
    @pos = options[:pos]
    @party_id = options[:party_id]
    @change_type_name = options[:change_type_name]
    @short_note = options[:short_note]
    @full_note = options[:full_note]
    @hash_full_note = options[:hash_full_note]
    @hash_ann_symbol = options[:hash_ann_symbol]
    @effective_at = options[:effective_at]
    @is_current = options[:is_current]
    @species_listing_name = options[:species_listing_name]
    @auto_note = options[:auto_note]
    @inclusion_taxon_concept_id = options[:inclusion_taxon_concept_id]
    @inherited_short_note = options[:inherited_short_note]
    @inherited_full_note = options[:inherited_full_note]
    @nomenclature_note = options[:nomenclature_note]
  end

  def is_addition?
    @change_type_name == ChangeType::ADDITION
  end

  def is_amendment?
    @change_type_name == 'AMENDMENT'
  end

  def is_deletion?
    @change_type_name == ChangeType::DELETION
  end

  def is_reservation?
    @change_type_name == ChangeType::RESERVATION
  end

  def is_reservation_withdrawal?
    @change_type_name == ChangeType::RESERVATION_WITHDRAWAL
  end

  def is_inclusion?
    !@inclusion_taxon_concept_id.nil?
  end

  def effective_at_formatted
    effective_at.strftime("%d/%m/%y")
  end

end
