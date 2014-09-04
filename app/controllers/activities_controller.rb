class ActivitiesController < ApplicationController
  layout 'activities_page'
	#def toptens
   # @toptens = Topten.order('count DESC')
  #end

	def activities
    @toptens = Topten.order('count DESC')
		   @data_taxon_concept = Ahoy::Event.select('count(*), extract(week from time) as week')
      .group('week').where(:name => "Taxon Concept" ).order('week')
    @data_search = Ahoy::Event.select('count(*), extract(week from time) as week')
      .group('week').where("name='Search'").order('week')
    gon.taxon_concept = ['Taxon Concept'] + @data_taxon_concept.map { |dtc| dtc.count.to_i }
    gon.search = ['Search'] + @data_search.map { |ds| ds.count.to_i }
    
    while gon.taxon_concept.length < gon.search.length 
      gon.taxon_concept.push 0                         
    end

    while gon.taxon_concept.length > gon.search.length
      gon.taxon_concept.push 0
    end
   end 
end		