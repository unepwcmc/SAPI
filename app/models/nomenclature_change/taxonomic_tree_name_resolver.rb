class NomenclatureChange::TaxonomicTreeNameResolver

  def initialize(taxon_concept)
    @node = taxon_concept
  end

  # turn taxa into synonyms when name changes involved
  def process
    resolve(@node)
  end


  private
  def resolve(node)
    unless name_compatible_with_parent?(node)
      compatible_node_attributes = {
        taxonomy_id: node.taxonomy_id,
        full_name: expected_name(node)
      }
      # find or create a new accepted name compatible with this parent
      compatible_node = TaxonConcept.where(compatible_node_attributes).first
      unless compatible_node
        compatible_node = TaxonConcept.create(
          compatible_node_attributes.merge({
            parent_id: node.parent_id,
            name_status: node.name_status,
            rank_id: node.rank_id
          })
        )
      else
        unless ['A', 'N'].include?(compatible_node.name_status)
          t = NomenclatureChange::ToAcceptedNameTransformation.new(compatible_node, node.parent)
          t.process
        end
      end
      # reassign everything to new name
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
    expected_name(node) == node.full_name
  end

  def expected_name(node)
    if node.rank &&
      Rank.in_range(Rank::VARIETY, Rank::SPECIES).include?(node.rank.name)
      node.parent.full_name + if node.rank.name == Rank::VARIETY
        ' var. '
      else
        ' '
      end + node.taxon_name.try(:scientific_name).try(:downcase)
    else
      node.full_name
    end
  end

end
