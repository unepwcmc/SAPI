module CascadeDeletable
  extend ActiveSupport::Concern

  def cascade_delete!
    cascade_delete_associated!
    cascade_nullify_associated!

    delete_all!
  end

  ##
  # Returns an array of `ActiveRecord::Reflection`s
  def self.cascade_deletable_associations
    reflect_on_all_associations.filter do |assoc|
      [ :has_many, :has_one ].includes(assoc.macro) &&
        assoc.has_inverse? &&
        !assoc.inverse_of.options[:optional]
    end
  end

  ##
  # Returns an array of `ActiveRecord::Reflection`s
  def self.cascade_nullable_associations
    reflect_on_all_associations.filter do |assoc|
      [ :has_many, :has_one ].includes(assoc.macro) &&
        assoc.has_inverse? &&
        assoc.inverse_of.options[:optional]
    end
  end

  def cascade_nullify_associated! (
    associations = self.class.cascade_nullable_associations
  )
    associations.each do |assoc|
      inverted_assoc_rel = assoc.klass.where(assoc.inverse_of.name => self)

      inverted_assoc_rel.update_all( # rubocop:disable Rails/SkipsModelValidations
        inverted_assoc_rel.foreign_key => nil
      )
    end
  end

  def cascade_delete_associated! (
    associations = self.class.cascade_deletable_associations
  )
    associations.each do |assoc|
      inverted_assoc_rel = assoc.klass.where(assoc.inverse_of.name => self)

      if inverted_assoc_rel.respond_to? :cascade_delete!
        inverted_assoc_rel.cascade_delete!
      else
        inverted_assoc_rel.delete_all
      end
    end
  end
end
