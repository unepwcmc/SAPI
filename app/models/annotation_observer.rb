class AnnotationObserver < ActiveRecord::Observer

  def before_save(annotation)
    if annotation.event
      annotation.parent_symbol = annotation.event.name
    end
  end

end
