class ActivitiesController < ApplicationController
  layout 'activities_page'

  def activities
    linechart_start_date = Ahoy::Event.minimum(:time)
    if linechart_start_date < 1.year.ago
      linechart_start_date = 1.year.ago
    end
    linechart_end_date = Time.now
    @start_week = params[:start_week] && Date.parse(params[:start_week])
    topten_start_date, topten_end_date =
      if @start_week
        start_date = @start_week
        [start_date, start_date + 7]
      else
        [linechart_start_date, linechart_end_date]
      end
    @toptens_cites = TaxonConceptViewStats.new(
      topten_start_date, topten_end_date, Taxonomy::CITES_EU
    ).results
    @toptens_cms = TaxonConceptViewStats.new(
      topten_start_date, topten_end_date, Taxonomy::CMS
    ).results
    data = EventsByTypeStats.new(linechart_start_date, linechart_end_date).data
    gon.taxon_concept = ['Taxon Concept'] + data.map(&:taxon_concept_cnt)
    gon.search = ['Search'] + data.map(&:search_cnt)
    gon.weeks = data.map(&:start_date)
  end
end
