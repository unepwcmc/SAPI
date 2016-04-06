class Admin::NamesController < Admin::SimpleCrudController
  belongs_to :taxon_concept

  before_filter :load_search
  layout 'taxon_concepts'

  authorize_resource :class => false

  def index
    @languages = Language.order(:name_en)
    @taxon_commons = @taxon_concept.taxon_commons.
      joins(:common_name).order('UPPER(common_names.name) ASC').
      includes(:common_name => :language)
    @synonym_relationships = @taxon_concept.synonym_relationships.
      includes(:other_taxon_concept).order('taxon_concepts.full_name')
    @trade_name_relationships = @taxon_concept.trade_name_relationships.
      includes(:other_taxon_concept).order('taxon_concepts.full_name')
    @hybrid_relationships = @taxon_concept.hybrid_relationships.
      includes(:other_taxon_concept).order('taxon_concepts.full_name')
  end

end
