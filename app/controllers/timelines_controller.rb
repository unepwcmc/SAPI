class TimelinesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  cache_sweeper :timeline_sweeper

  def index
    return render :json => []  if params[:taxon_concept_ids].nil?

    taxon_concept_ids = params[:taxon_concept_ids].split(',')
    res = taxon_concept_ids.map do |id|
      TimelinesForTaxonConcept.new(id).serializable_hash(
      :only => [:id, :taxon_concept_id],
      :methods => [:timeline_years],
      :include => [
        :timelines => {
          :only => [:id, :appendix, :party, :parties],
          :include => [
            :timeline_events,
            :timeline_intervals,
            {:timelines => {
              :only => [:id, :appendix, :party],
              :include => [
                :timeline_events,
                :timeline_intervals
              ]
            }}
          ]
        }
      ]
      )
    end
    render :json => res
  end
end
