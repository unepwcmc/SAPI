class ActivitiesController < ApplicationController
  layout 'activities_page'
	
	def activities
    @toptens_cites = ToptensCite.order('number_of_visits DESC')
    @toptens_cms = ToptensCm.order('number_of_visits DESC')
		@data_taxon_concept = Ahoy::Event.select('count(*), extract(week from time) as week, extract(year from time) as year').group('week,year').where(:name => "Taxon Concept" ).order('year,week')
    @data_search = Ahoy::Event.select('count(*), extract(week from time) as week, extract(year from time) as year').group('week,year').where(:name=> "Search").order('year,week')
    gon.taxon_concept = ['Taxon Concept'] + @data_taxon_concept.map { |dtc| dtc.count.to_i }
    gon.search = ['Search'] + @data_search.map { |ds| ds.count.to_i }
    gon.weeks = (@data_taxon_concept + @data_search).map { |dtc| Date.strptime(dtc.year + "." + dtc.week, "%G.%V") }
    gon.weeks.sort!.uniq!.map! { |gw| gw.to_s(:iso8601) }

    while gon.taxon_concept.length < gon.search.length 
      gon.taxon_concept.push 0                         
    end

    while gon.taxon_concept.length > gon.search.length
      gon.taxon_concept.push 0
    end
  end 
end		