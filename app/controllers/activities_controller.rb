class ActivitiesController < ApplicationController
  layout 'activities_page'

  def activities
    @toptens_cites = TaxonConceptViewStats.cites_eu.
      order('number_of_visits DESC').limit(10)
    @toptens_cms = TaxonConceptViewStats.cms.
      order('number_of_visits DESC').limit(10)

    start_date = Ahoy::Event.minimum(:time)
    if start_date < 1.year.ago
      start_date = 1.year.ago
    end
    end_date = Time.now
    data = EventsByTypeStats.new(start_date, end_date).data
    gon.taxon_concept = ['Taxon Concept'] + data.map(&:taxon_concept_cnt)
    gon.search = ['Search'] + data.map(&:search_cnt)
    gon.weeks = data.map(&:start_date)
    if params["start_week"]
      @weekly_topten = WeekTopten.new(params["start_week"]).data
    else
      @weekly_topten = []
    end
  end
end
