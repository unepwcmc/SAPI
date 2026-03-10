module CascadeDeletable
  extend ActiveSupport::Concern

  class_methods do
    def cascade_delete!
      cascade_delete_associated!
      cascade_nullify_associated!

      delete_all
    end

    ##
    # Returns an array of `ActiveRecord::Reflection`s
    def cascade_deletable_associations
      reflect_on_all_associations.filter do |assoc|
        [ :has_many, :has_one ].include?(assoc.macro) &&
          assoc.has_inverse? &&
          !assoc.inverse_of.options[:optional]
      end
    end

    ##
    # Returns an array of `ActiveRecord::Reflection`s
    def cascade_nullable_associations
      reflect_on_all_associations.filter do |assoc|
        [ :has_many, :has_one ].include?(assoc.macro) &&
          assoc.has_inverse? &&
          assoc.inverse_of.options[:optional]
      end
    end

    def cascade_nullify_associated! (
      nullable_associations = cascade_nullable_associations
    )
      if limit(1).count > 0
        nullable_associations.each do |assoc|
          inverted_assoc_rel = assoc.klass.where(assoc.inverse_of.name => all)

          inverted_assoc_rel.update_all( # rubocop:disable Rails/SkipsModelValidations
            assoc.inverse_of.foreign_key => nil
          )
        end
      end
    end

    def cascade_delete_associated! (
      deletable_associations = cascade_deletable_associations
    )
      if limit(1).count > 0
        deletable_associations.each do |assoc|
          inverted_assoc_rel = assoc.klass.where(assoc.inverse_of.name => all)

          if inverted_assoc_rel.respond_to? :cascade_delete!
            inverted_assoc_rel.cascade_delete!
          else
            inverted_assoc_rel.delete_all
          end
        end
      end
    end
  end
end
