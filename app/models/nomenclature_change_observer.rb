class NomenclatureChangeObserver < ActiveRecord::Observer

  def after_save(nomenclature_change)
    if nomenclature_change.status == nomenclature_change.class::SUBMITTED
      Rails.logger.warn "SUBMIT #{nomenclature_change.type}"
      begin
        processor_klass = "#{nomenclature_change.type}::Processor".constantize
      rescue NameError
        Rails.logger.warn "No processor found for #{nomenclature_change.type}"
      else
        processor_klass.new(nomenclature_change).run
      end
    end
  end

end
