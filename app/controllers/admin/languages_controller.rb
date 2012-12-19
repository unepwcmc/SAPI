class Admin::LanguagesController < Admin::SimpleCrudController
  inherit_resources

  protected
    def collection
      @languages ||= end_of_association_chain.order(:iso_code1).page(params[:page])
    end
end
