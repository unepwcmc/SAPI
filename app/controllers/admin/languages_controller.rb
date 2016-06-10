class Admin::LanguagesController < Admin::StandardAuthorizationController

  protected

    def collection
      @languages ||= end_of_association_chain.order(:iso_code3).
        page(params[:page]).
        search(params[:query])
    end
end
