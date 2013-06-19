class Admin::LanguagesController < Admin::SimpleCrudController

  protected
    def collection
      @languages ||= end_of_association_chain.order(:iso_code3).page(params[:page])
    end
end
