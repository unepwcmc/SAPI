class Admin::NamesController < Admin::SimpleCrudController
  belongs_to :taxon_concept
  before_filter :load_search
  layout 'taxon_concepts'

  def index
    @languages = Language.order(:name_en)
    @taxon_commons = @taxon_concept.taxon_commons.
      joins(:common_name).order('UPPER(common_names.name) ASC').
      includes(:common_name => :language)
  end
end
