class NomenclatureChange::Split < NomenclatureChange
  STEPS = [:inputs, :outputs, :notes, :children, :names, :distribution, :legislation, :summary]
  STATUSES = ['new', 'submitted'] + STEPS.map(&:to_s)
  build_basic_dictionary(*STATUSES)
  has_one :input, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Input,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  has_many :outputs, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  accepts_nested_attributes_for :input, :allow_destroy => true
  accepts_nested_attributes_for :outputs, :allow_destroy => true

  validates :status, inclusion: {
    in: STATUSES,
    message: "%{value} is not a valid status"
  }
  validate :required_inputs, if: :inputs_or_submitting?
  validate :required_outputs, if: :outputs_or_submitting?
  validate :required_ranks, if: :outputs_or_submitting?

  def required_inputs
    if input.blank?
      errors.add(:input, "Must have one input")
      return false
    end
  end

  def required_outputs
    if outputs.size < 2
      errors.add(:outputs, "Must have at least two outputs")
      return false
    end
  end

  def required_ranks
    if !(outputs.map{ |o| o.new_rank.try(:name) || o.taxon_concept.try(:rank).try(:name) }.
      uniq - [input.try(:taxon_concept).try(:rank).try(:name)]).empty?
      errors.add(:outputs, "Must be at same rank as input")
      return false
    end
  end

end
