##
# See also ProtectedDeletion, which all Deletable classes must also include.
#
# This module implements a hook `before_destroy_checking`. Classes which include
# Deletable will not delete if "dependent objects" are present, which should be
# those which have a has_one or has_many relationship and no cascade deletion
# or nullification of the foreign key.
module Deletable
  extend ActiveSupport::Concern

  included do
    before_destroy :before_destroy_checking
  end

  def destroy
    super
  rescue StandardError => e
    errors.add(:base, e.message)

    raise e
  ensure
    if !destroyed? && errors.blank?
      errors.add(:base, "Unknown error during destroy of #{self.class.model_name.singular} #{id}")
    end
  end

private

  def before_destroy_checking
    unless can_be_deleted?
      msg = 'not allowed'

      unless dependent_objects.empty?
        msg << " (dependent objects present: #{dependent_objects.join(', ')})"
      end

      errors.add(:base, msg)

      # When deleting A has_many B has_many C, and C is blocking deletion of B
      # Then store the error on A also so that inherited_resources knows that
      # a failure has happened.
      if RequestStore.store[:original_resource_to_delete] != self
        RequestStore.store[:original_resource_to_delete]&.errors&.add(
          :base, "#{self.class.model_name.singular.capitalise} #{id}: #{msg}"
        )
      end

      # Throw rather than raise per:
      # https://api.rubyonrails.org/classes/ActiveRecord/RecordNotDestroyed.html
      throw :abort
    end
  end
end
