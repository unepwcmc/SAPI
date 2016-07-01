class Admin::CitesSuspensionsController < Admin::StandardAuthorizationController
  before_filter :load_lib_objects, :only => [:new, :edit]

  def create
    create! do |success, failure|
      success.html {
        redirect_to admin_cites_suspensions_url,
        :notice => 'Operation successful'
      }
      failure.html {
        load_lib_objects
        render 'new'
      }
    end
  end

  def update
    update! do |success, failure|
      success.html {
        redirect_to admin_cites_suspensions_url,
        :notice => 'Operation successful'
      }
      failure.html {
        load_lib_objects
        render 'edit'
      }
    end
  end

  protected

  def load_lib_objects
    @current_suspensions = CitesSuspension.
      where(:is_current => true).
      where(:taxon_concept_id => nil)
    @units = Unit.order(:code)
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @purposes = Purpose.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true,
            :geo_entity_types => { :name => GeoEntityType::SETS[GeoEntityType::DEFAULT_SET] })
    @suspension_notifications = CitesSuspensionNotification.
      select([:id, :name]).
      order('effective_at DESC')
  end

  def collection
    @cites_suspensions ||= end_of_association_chain.order('start_date DESC').
      page(params[:page]).search(params[:query])
  end
end
