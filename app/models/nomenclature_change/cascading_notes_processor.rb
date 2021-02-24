class NomenclatureChange::CascadingNotesProcessor

  def initialize(input_or_output)
    @input_or_output = input_or_output
  end

  def run
    @taxon_concept =
      if @input_or_output.kind_of? NomenclatureChange::Output
        @input_or_output.new_taxon_concept || @input_or_output.taxon_concept
      else
        @input_or_output.taxon_concept
      end
    return false unless @taxon_concept
    descendents_for_note_cascading(@taxon_concept).each do |d|
      Rails.logger.debug("Processing note for descendant #{d.full_name} of input #{@taxon_concept.full_name}")
      append_nomenclature_notes(d, @input_or_output)
      (
        d.listing_changes +
        d.cites_suspensions +
        d.quotas +
        d.eu_opinions +
        d.eu_suspensions
      ).each do |legislation|
        append_nomenclature_notes_to_legislation(legislation, @input_or_output)
      end
    end
  end

  def summary
    []
  end

  private

  def descendents_for_note_cascading(taxon_concept)
    unless [Rank::GENUS, Rank::SPECIES].include? taxon_concept.rank.try(:name)
      return []
    end
    # if it is a genus or a species, we want taxon-level nomenclature notes,
    # both public and private, to cascade to descendents
    subquery = <<-SQL
      WITH RECURSIVE descendents AS (
        SELECT id,
          full_name,
          rank_id,
          parent_id,
          taxon_name_id,
          taxonomy_id,
          name_status,
          created_at,
          updated_at,
          nomenclature_note_en,
          nomenclature_note_es,
          nomenclature_note_fr
        FROM taxon_concepts
        WHERE parent_id = :taxon_concept_id
        UNION ALL
        SELECT taxon_concepts.id,
          taxon_concepts.full_name,
          taxon_concepts.rank_id,
          taxon_concepts.parent_id,
          taxon_concepts.taxon_name_id,
          taxon_concepts.taxonomy_id,
          taxon_concepts.name_status,
          taxon_concepts.created_at,
          taxon_concepts.updated_at,
          taxon_concepts.nomenclature_note_en,
          taxon_concepts.nomenclature_note_es,
          taxon_concepts.nomenclature_note_fr
        FROM taxon_concepts
        JOIN descendents h ON h.id = taxon_concepts.parent_id
      )
      SELECT * FROM descendents
    SQL
    sanitized_subquery = ActiveRecord::Base.send(
      :sanitize_sql_array, [subquery, taxon_concept_id: taxon_concept.id]
    )
    TaxonConcept.from(
      "(#{sanitized_subquery}) taxon_concepts"
    )
  end

  def append_nomenclature_notes(tc, input_or_output)
    tc.nomenclature_note_en = "#{tc.nomenclature_note_en} #{input_or_output.note_en}"
    tc.nomenclature_note_es = "#{tc.nomenclature_note_es} #{input_or_output.note_es}"
    tc.nomenclature_note_fr = "#{tc.nomenclature_note_fr} #{input_or_output.note_fr}"
    tc.save(validate: false)
    nomenclature_comment = tc.nomenclature_comment ||
      tc.create_nomenclature_comment
    nomenclature_comment.update_attribute(
      :note,
      "#{nomenclature_comment.note} #{input_or_output.internal_note}"
    )
  end

  def append_nomenclature_notes_to_legislation(legislation, input_or_output)
    legislation.nomenclature_note_en = "#{legislation.nomenclature_note_en} #{input_or_output.note_en}"
    legislation.nomenclature_note_es = "#{legislation.nomenclature_note_es} #{input_or_output.note_es}"
    legislation.nomenclature_note_fr = "#{legislation.nomenclature_note_fr} #{input_or_output.note_fr}"
    legislation.internal_notes = "#{legislation.internal_notes} #{input_or_output.internal_note}"
    legislation.save(validate: false)
  end

end
