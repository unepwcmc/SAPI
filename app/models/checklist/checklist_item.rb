#this class is possibly redundant
class Checklist::ChecklistItem
  #[:full_name].each { |f| attr_accessor f }

  def initialize(options)
    options.each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end

end