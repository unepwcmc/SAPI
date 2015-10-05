#  event_id      :integer
#  type          :string(255)      not null
#  status        :string(255)      not null
#  created_by_id :integer          not null
#  updated_by_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null

class NomenclatureChange::NewName < NomenclatureChange
  build_steps(:name_status, :taxonomy, :rank, :parent, :accepted_names,
    :hybrid_parents, :scientific_name, :author_year,
    :nomenclature_notes, :summary)
  attr_accessible :output_attributes

  has_one :output, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy

  accepts_nested_attributes_for :output, :allow_destroy => true

  validates :status, inclusion: {
    in: self.status_dict,
    message: "%{value} is not a valid status"
  }
  validate :required_different_name, if: :scientific_name_step?
  validate :parent_at_immediately_higher_rank, if: :parent_step?
  validate :required_accepted_names, if: :accepted_names_step?
  validate :required_hybrids, if: :hybrid_parents_step?

  def scientific_name_step?
    status == 'scientific_name'
  end

  def parent_step?
    status == 'parent'
  end

  def accepted_names_step?
    status == 'accepted_names'
  end

  def hybrid_parents_step?
    status == 'hybrid_parents'
  end

  def required_accepted_names
    if output.present?
      unless output.accepted_taxon_ids.present?
        errors.add(:outputs, "at least an accepted name is required")
        return false
      end
    end
  end

  def required_hybrids
    if output.present?
      unless output.hybrid_parent_id && output.other_hybrid_parent_id
        errors.add(:outputs, "Hybrid parents are required")
        return false;
      end
    end
  end

  def required_different_name
    if output.present?
      if output.new_full_name.nil?
        errors.add(:outputs, "Scientific name is required")
        return false
      elsif output.taxon_name_already_existing? && 
        !output.new_full_name.nil?
        errors.add(:outputs, "Name already existing")
        return false
      end
    end
  end

  def new_output_parent
    nil
  end

  def parent_at_immediately_higher_rank
    return true if (output.new_parent.rank.name == 'KINGDOM' && output.new_parent.full_name == 'Plantae' && output.new_rank.name == 'ORDER')
    unless output.new_parent.rank.taxonomic_position >= output.new_rank.parent_rank_lower_bound &&
      output.new_parent.rank.taxonomic_position < output.new_rank.taxonomic_position
      errors.add(:new_parent_id, "must be at immediately higher rank")
      return false
    end
  end

end
