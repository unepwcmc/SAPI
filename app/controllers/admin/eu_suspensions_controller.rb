class Admin::EuSuspensionsController < Admin::SimpleCrudController
  belongs_to :eu_suspension_regulation


  protected
  def collection
    @eu_suspensions ||= end_of_association_chain.
      includes([
        :geo_entity,
        :taxon_concept
      ]).
      page(params[:page]).per(200).#where(:parent_id => nil).
      order('taxon_concepts.full_name ASC, eu_decisions.start_date DESC').
      search(params[:query])
  end
end