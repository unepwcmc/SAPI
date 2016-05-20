class Admin::EventDocumentsController < Admin::SimpleCrudController
  defaults :resource_class => Document,
    :collection_name => 'documents', :instance_name => 'document'
  belongs_to :event

  def reorder; end
end
