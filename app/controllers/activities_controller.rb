class ActivitiesController < ApplicationController
	layout 'activities'
	def toptens
		@toptens = Topten.order('count DESC')
	end
end		