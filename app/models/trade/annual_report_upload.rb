class Trade::AnnualReportUpload
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::Serialization
  attr_accessor :attachment

  def initialize(attributes = {})

  end

  def copy_to_sandbox

  end

  def persisted?
    false
  end

end
