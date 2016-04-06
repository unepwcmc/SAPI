module NormaliseBlankValues extend ActiveSupport::Concern

  def self.included(base)
    base.extend ClassMethods
  end

  def normalise_blank_values
    attributes.each do |column, value|
      self[column].present? || self[column] = nil
    end
  end

  module ClassMethods
    def normalise_blank_values
      before_save :normalise_blank_values
    end
  end

end

ActiveRecord::Base.send(:include, NormaliseBlankValues)
