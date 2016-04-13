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
    expected_full_name = node.expected_full_name(node.parent)

    expected_scientific_name = if ['A', 'N'].include?(node.name_status)
      expected_full_name.split.last
    else
      expected_full_name
    end

    Rails.logger.debug("Resolving node name: #{node.full_name} (expected: #{expected_full_name})")
    unless name_compatible_with_parent?(node)
      # find or create a new accepted name compatible with this parent
      compatible_node = TaxonConcept.where(
        taxonomy_id: node.taxonomy_id,
        full_name: expected_full_name
      ).first
      unless compatible_node
        compatible_node = TaxonConcept.create(
          taxonomy_id: node.taxonomy_id,
          scientific_name: expected_scientific_name,
          parent_id: node.parent_id,
          name_status: node.name_status,
          rank_id: node.rank_id,
          author_year: node.author_year
        )
      else
        unless ['A', 'N'].include?(compatible_node.name_status)
          t = NomenclatureChange::ToAcceptedNameTransformation.new(compatible_node, node.parent)
          t.process
        end
      end
      # restore old parent, even though this ends up as a synonym it should
      # have sane ancestry
      node.update_attribute(:parent_id, @node_old_copy.parent_id)
      r = NomenclatureChange::FullReassignment.new(node, compatible_node)
      r.process
      t = NomenclatureChange::ToSynonymTransformation.new(node, compatible_node)
      t.process
    else
      compatible_node = node
    end

    compatible_node.children.each do |child_node|
      resolve(child_node)
    end
  end

  def name_compatible_with_parent?(node)
    node.expected_full_name(node.parent) == node.full_name
  end

end
