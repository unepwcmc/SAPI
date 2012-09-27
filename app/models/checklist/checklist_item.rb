class Checklist::ChecklistItem
  TaxonConceptM::EXPORTED_FIELDS.each { |f| attr_accessor f }

  def initialize(options)
    options.each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end

end