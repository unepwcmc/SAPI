class Admin::LanguagesController < Admin::AdminController
  inherit_resources

  protected
    def collection
      @languages ||= end_of_association_chain.order(:iso_code1)
    end
end
