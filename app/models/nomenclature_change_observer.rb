class NomenclatureChangeObserver < ActiveRecord::Observer

  def before_save(nomenclature_change)
    if nomenclature_change.status == 'submitted' && nomenclature_change.status_changed?
      processor_klass = "#{nomenclature_change.type}::Processor".constantize
      processor_klass.new(nomenclature_change).run
    end
  end

end