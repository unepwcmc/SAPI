class EventObserver < ActiveRecord::Observer
  def after_create(event)
    #TODO copy listing changes
  end
end