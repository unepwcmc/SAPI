# Who may see and change the intertaxonomic mapping data.
#
# The three controllers behind the Taxon Mapping page do not share a base class
# - one of them is an inherit_resources CRUD, the others are plain - so the one
# rule they do share lives here rather than being written out three times.
module TaxonMappingAccess
  extend ActiveSupport::Concern

  included do
    before_action :authorise_batch_updates!
  end

private

  def authorise_batch_updates!
    raise CanCan::AccessDenied unless current_user&.is_manager_or_secretariat?
  end
end
