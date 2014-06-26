class NomenclatureChange::Lump < NomenclatureChange
  STEPS = [:inputs, :outputs, :children, :names, :distribution, :legislation, :notes, :summary]
  STATUSES = ['new', 'submitted'] + STEPS.map(&:to_s)
  build_basic_dictionary(*STATUSES)
  has_one :output, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Input,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  has_many :inputs, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  accepts_nested_attributes_for :inputs, :allow_destroy => true
  accepts_nested_attributes_for :output, :allow_destroy => true

  validates :status, inclusion: {
    in: STATUSES,
    message: "%{value} is not a valid status"
  }
  validate :required_inputs, if: :inputs_or_submitting?
  validate :required_outputs, if: :outputs_or_submitting?
  validate :required_ranks, if: :outputs_or_submitting?

  def required_inputs
    if inputs.size < 2
      errors.add(:inputs, "Must have at least two inputs")
      return false
    end
  end

  def required_outputs
    if output.blank?
      errors.add(:output, "Must have one output")
      return false
    end
  end

  def required_ranks
    if !(inputs.map{ |i| i.new_rank.try(:name) || i.taxon_concept.try(:rank).try(:name) }.
      uniq - [output.try(:taxon_concept).try(:rank).try(:name)]).empty?
      errors.add(:outputs, "Must be at same rank as inputs")
      return false
    end
  end

end
