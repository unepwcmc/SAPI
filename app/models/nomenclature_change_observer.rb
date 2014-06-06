class NomenclatureChangeObserver < ActiveRecord::Observer

  def before_save(nomenclature_change)
    if nomenclature_change.status == 'submitted' && nomenclature_change.status_changed?
      nomenclature_change.process
    end
  end

end