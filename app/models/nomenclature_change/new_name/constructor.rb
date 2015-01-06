class NomenclatureChange::NewName::Constructor
  include NomenclatureChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
  end

  def build_output
    @nomenclature_change.build_output if @nomenclature_change.output.nil?
  end

end