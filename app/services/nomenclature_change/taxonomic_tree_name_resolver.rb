class NomenclatureChange::TaxonomicTreeNameResolver

  def initialize(taxon_concept, taxon_concept_old_copy)
    @node = taxon_concept
    @node_old_copy = taxon_concept_old_copy
  end

  # turn taxa into synonyms when name changes involved
  def process
    resolve(@node)
  end

  private

  def resolve(node)
    @expected_full_name = node.expected_full_name(node.parent)
    return node if name_compatible_with_parent?(node)
    Rails.logger.debug("Resolving node name: #{node.full_name} (expected: #{@expected_full_name})")

    # find or create a new accepted name compatible with this parent
    compatible_node = TaxonConcept.where(
      taxonomy_id: node.taxonomy_id,
      full_name: @expected_full_name
    )
    # match on author & year as well
    compatible_node =
      if node.author_year.blank?
        compatible_node.where('SQUISH_NULL(author_year) IS NULL')
      else
        compatible_node.where(author_year: node.author_year)
      end.first
    if !compatible_node
      compatible_node = create_compatible_node(node)
    elsif compatible_node && !['A', 'N'].include?(compatible_node.name_status)
      upgrade_node(compatible_node, node.parent)
    end

    # restore old parent, even though this ends up as a synonym it should
    # have sane ancestry
    node.update_attribute(:parent_id, @node_old_copy.parent_id)

    r = NomenclatureChange::FullReassignment.new(node, compatible_node)
    r.process
    downgrade_node(node, compatible_node)

    node.children.each do |child_node|
      child_node.parent = compatible_node
      resolve(child_node)
    end
  end

  def create_compatible_node(node)
    expected_scientific_name =
      if ['A', 'N'].include?(node.name_status)
        @expected_full_name.split.last
      else
        @expected_full_name
      end
    compatible_node = TaxonConcept.create(
      taxonomy_id: node.taxonomy_id,
      scientific_name: expected_scientific_name,
      parent_id: node.parent_id,
      name_status: node.name_status,
      rank_id: node.rank_id,
      author_year: node.author_year,
      nomenclature_note_en: node.nomenclature_note_en,
      nomenclature_note_es: node.nomenclature_note_es,
      nomenclature_note_fr: node.nomenclature_note_fr
    )
    if node.nomenclature_comment
      compatible_node.create_nomenclature_comment(note: node.nomenclature_comment.note)
    end
    compatible_node
  end

  def upgrade_node(node, parent)
    t = NomenclatureChange::ToAcceptedNameTransformation.new(node, parent)
    t.process
  end

  def downgrade_node(node, compatible_node)
    t = NomenclatureChange::ToSynonymTransformation.new(node, compatible_node)
    t.process
  end

  def name_compatible_with_parent?(node)
    @expected_full_name == node.full_name
  end

end
