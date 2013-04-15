class Admin::LanguagesController < Admin::SimpleCrudController

  protected
    def collection
      @languages ||= end_of_association_chain.order(:iso_code1).
        page(params[:page]).
        search(params[:query])
    end
end
