# The taxonomies the mapping service can resolve between.
#
# Deliberately absent from the top bar: it is reached from the Taxon Mapping
# page, which is the only place its contents mean anything. Adding one is
# something you do because a file for it is about to be uploaded.
#
# Namespaced rather than named for what it holds, so the page can be called
# what the domain calls it without colliding with Core Data's Taxonomies, which
# are a different thing entirely.
class Admin::TaxonMappings::TaxonomiesController < Admin::SimpleCrudController
  defaults resource_class: MatchableTaxonomy,
    collection_name: 'taxonomies',
    instance_name: 'taxonomy'

  include TaxonMappingAccess

  # Re-declared because the parent binds js to :create alone, and naming a mime
  # here replaces its entry rather than adding to it. inherit_resources' own
  # edit then renders edit.js.erb, which fills the rename modal.
  respond_to :js, only: [ :create, :edit, :update ]

protected

  def collection
    # Paginated because the shared index template expects it, not because six
    # rows need it.
    @taxonomies ||= end_of_association_chain.order(:code).page(params[:page])
  end

private

  # The code is only settable when the row is created. It is what the API is
  # addressed by, so renaming one would break every caller already using it -
  # and the rows already loaded against it name the taxonomy by id, not by code,
  # so nothing here would fail loudly.
  def taxonomy_params
    return params.expect(taxonomy: [ :name ]) if action_name == 'update'

    params.expect(taxonomy: [ :code, :name ])
  end
end
