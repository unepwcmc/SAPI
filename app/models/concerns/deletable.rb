module Deletable
  extend ActiveSupport::Concern

  included do
    before_destroy :before_destroy_checking
  end

  private

  def before_destroy_checking
    unless can_be_deleted?
      msg = 'not allowed'
      unless dependent_objects.empty?
        msg << " (dependent objects present: #{dependent_objects.join(', ')})"
      end
      errors.add(:base, msg)
      throw :abort
    end
  end
end
