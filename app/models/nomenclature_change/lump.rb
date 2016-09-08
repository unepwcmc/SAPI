# == Schema Information
#
# Table name: nomenclature_changes
#
#  id            :integer          not null, primary key
#  event_id      :integer
#  type          :string(255)      not null
#  status        :string(255)      not null
#  created_by_id :integer          not null
#  updated_by_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class NomenclatureChange::Lump < NomenclatureChange
  build_steps(:inputs, :outputs, :notes, :legislation, :summary)
  attr_accessible :inputs_attributes, :output_attributes
  has_many :inputs, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Input,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  has_one :output, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  accepts_nested_attributes_for :inputs, :allow_destroy => true
  accepts_nested_attributes_for :output, :allow_destroy => true

  validates :status, inclusion: {
    in: self.status_dict,
    message: "%{value} is not a valid status"
  }
  validate :required_inputs, if: :inputs_or_submitting?
  validate :required_outputs, if: :outputs_or_submitting?
  before_validation :set_output_name_status, if: Proc.new { |nc|
    !nc.inputs.empty? && nc.output && nc.outputs_or_submitting?
  }
  before_save :build_auto_reassignments, if: :notes?

  def build_auto_reassignments
    unless inputs.empty?
      builder = NomenclatureChange::Lump::Constructor.new(self)
      builder.build_legislation_reassignments
      builder.build_common_names_reassignments
      builder.build_references_reassignments
    end
    true
  end

  def required_inputs
    if inputs.size < 2
      errors.add(:inputs, "Must have at least two inputs")
      return false
    end
  end

  def required_outputs
    unless output
      errors.add(:output, "Must have one output")
      return false
    end
  end

  def set_output_name_status
    if output.new_name_status.blank? && (
      output.new_scientific_name.present? ||
      output.taxon_concept && output.taxon_concept.name_status != 'A'
      )
      output.new_name_status = 'A'
    end
  end

  def inputs_except_outputs
    inputs.reject { |i| i.taxon_concept == output.try(:taxon_concept) }
  end

  def inputs_intersect_outputs
    inputs.select { |o| o.taxon_concept == output.try(:taxon_concept) }
  end

  def new_output_rank
    inputs.first.taxon_concept.rank
  end

  def new_output_parent
    inputs.first.taxon_concept.parent
  end
end
