class NomenclatureChangeObserver < ActiveRecord::Observer

  def before_save(nomenclature_change)
    if nomenclature_change.submitting?
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