class Admin::ChildrenController < Admin::SimpleCrudController
  belongs_to :taxon_concept
  before_filter :load_search
  layout 'taxon_concepts'

  def index
    @children = @taxon_concept.children.
      where(:name_status => 'A').
      order(:full_name)
  end
end
