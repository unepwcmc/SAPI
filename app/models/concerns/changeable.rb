module Changeable
  extend ActiveSupport::Concern

  included do
    #########################################################
    ### after save
    after_save :changeable_after_save_callback
    after_commit :changeable_after_save_callback_on_commit, on: [:create, :update]
    #########################################################
    ### before destroy
    before_destroy :changeable_before_destroy_callback
    after_commit :changeable_before_destroy_callback_on_commit, on: :destroy
  end

  private

  def changeable_before_destroy_callback
    if respond_to?(:taxon_concept) && taxon_concept && can_be_deleted?
      # currently no easy means to tell who deleted the dependent object
      changeable_bump_dependents_timestamp_part_one(taxon_concept, nil)
    end
  end

  def changeable_before_destroy_callback_on_commit
    changeable_clear_cache
    if respond_to?(:taxon_concept) && taxon_concept && can_be_deleted?
      # currently no easy means to tell who deleted the dependent object
      changeable_bump_dependents_timestamp_part_two
    end
  end

  def changeable_after_save_callback
    unless respond_to?(:taxon_concept)
      return
    end

    if taxon_concept
      changeable_bump_dependents_timestamp_part_one(taxon_concept, updated_by_id)
    end
    # Rails 5.1 to 5.2
    # DEPRECATION WARNING: The behavior of `attribute_was` inside of after callbacks will be changing in the next version of Rails.
    # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
    # To maintain the current behavior, use `attribute_before_last_save` instead.
    #
    # DEPRECATION WARNING: The behavior of `attribute_changed?` inside of after callbacks will be changing in the next version of Rails.
    # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
    # To maintain the current behavior, use `saved_change_to_attribute?` instead.
    #
    # DEPRECATION WARNING: The behavior of `changed_attributes` inside of after callbacks will be changing in the next version of Rails.
    # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
    # To maintain the current behavior, use `saved_changes.transform_values(&:first)` instead.
    #
    # == Original code ==
    # if taxon_concept.nil? && taxon_concept_id_was ||
    #   taxon_concept && taxon_concept_id_was && taxon_concept_id != taxon_concept_id_was
    #   previous_taxon_concept = TaxonConcept.find_by_id(taxon_concept_id_was)
    #   if previous_taxon_concept
    #     bump_dependents_timestamp(previous_taxon_concept, updated_by_id)
    #   end
    # end
    # == Changed to fix deprecation warnings ==
    if taxon_concept.nil? && taxon_concept_id_before_last_save ||
      taxon_concept && taxon_concept_id_before_last_save && taxon_concept_id != taxon_concept_id_before_last_save
      previous_taxon_concept = TaxonConcept.find_by_id(taxon_concept_id_before_last_save)
      if previous_taxon_concept
        changeable_bump_dependents_timestamp_part_one(previous_taxon_concept, updated_by_id)
      end
    end
  end

  def changeable_after_save_callback_on_commit
    changeable_clear_cache

    # For models that are not directly related to taxon concepts
    # but for which is anyway preferable for the changes to be reflacted
    # immedtiately on the public interface, clear the entire serializer cache.
    # Models like GeoEntity and Language are not directly linked to TaxonConcept,
    # so bumping the dependents_updated_at timestamp seems a bit confusing.
    # Also there's currently no easy way to tell who updated those objects.
    # It's quite rare that updates to those objects will occur,
    # so there shouldn't be no harm in clearning the entire serializer cache.
    unless respond_to?(:taxon_concept)
      changeable_clear_show_tc_serializer_cache
      return
    end

    if taxon_concept
      changeable_bump_dependents_timestamp_part_two
    end
    # Rails 5.1 to 5.2
    # DEPRECATION WARNING: The behavior of `attribute_was` inside of after callbacks will be changing in the next version of Rails.
    # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
    # To maintain the current behavior, use `attribute_before_last_save` instead.
    #
    # DEPRECATION WARNING: The behavior of `attribute_changed?` inside of after callbacks will be changing in the next version of Rails.
    # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
    # To maintain the current behavior, use `saved_change_to_attribute?` instead.
    #
    # DEPRECATION WARNING: The behavior of `changed_attributes` inside of after callbacks will be changing in the next version of Rails.
    # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
    # To maintain the current behavior, use `saved_changes.transform_values(&:first)` instead.
    #
    # == Original code ==
    # if taxon_concept.nil? && taxon_concept_id_was ||
    #   taxon_concept && taxon_concept_id_was && taxon_concept_id != taxon_concept_id_was
    #   previous_taxon_concept = TaxonConcept.find_by_id(taxon_concept_id_was)
    #   if previous_taxon_concept
    #     bump_dependents_timestamp(previous_taxon_concept, updated_by_id)
    #   end
    # end
    # == Changed to fix deprecation warnings ==
    if taxon_concept.nil? && taxon_concept_id_before_last_save ||
      taxon_concept && taxon_concept_id_before_last_save && taxon_concept_id != taxon_concept_id_before_last_save
      previous_taxon_concept = TaxonConcept.find_by_id(taxon_concept_id_before_last_save)
      if previous_taxon_concept
        changeable_bump_dependents_timestamp_part_two
      end
    end
  end

  def changeable_clear_cache
    return unless respond_to?(:taxon_concept)

    DownloadsCacheCleanupWorker.perform_async(self.class.to_s.tableize)
  end

  def changeable_bump_dependents_timestamp_part_one(taxon_concept, updated_by_id)
    return unless taxon_concept

    TaxonConcept.where(id: taxon_concept.id).update_all(
      dependents_updated_at: Time.now,
      dependents_updated_by_id: updated_by_id
    )
  end

  def changeable_bump_dependents_timestamp_part_two
    return unless taxon_concept

    DownloadsCacheCleanupWorker.perform_async('taxon_concepts')
  end

  def changeable_clear_show_tc_serializer_cache
    ##
    # Disabling because we use memcache on production, but memcache doesn't implement this method.
    # For now, changes to records that appear in serializers will not change until the caches are expired,
    # which is 24 hours. Possible solution:
    # https://unep-wcmc.codebasehq.com/projects/cites-support-maintenance/tickets/114

    Rails.cache.delete_matched('*ShowTaxonConceptSerializer*') unless Rails.env.production?
  end
end
