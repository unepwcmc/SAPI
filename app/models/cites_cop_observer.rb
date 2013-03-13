class CitesCopObserver < ActiveRecord::Observer

  def after_initialize(cites_cop)
    cites = Designation.find_by_name('CITES')
    cites_cop.designation_id = cites && cites.id
  end

end