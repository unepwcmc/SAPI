class Admin::UsersController < Admin::SimpleCrudController
  respond_to :js, :except => [:index, :destroy]

  load_and_authorize_resource :except => :index

  def new
    new! do
      load_associations
    end
  end

  def edit
    edit! do |format|
      load_associations
      format.js { render 'new' }
    end
  end

  def update
    update_result =
      if params[:user][:password].blank?
        @user.update_without_password(params[:user])
      else
        @user.update_attributes(params[:user])
      end
    respond_to do |format|
      format.js {
        if update_result
          render 'create'
        else
          load_associations
          render 'new'
        end
      }
    end
  end

  protected

  def collection
    @users ||= end_of_association_chain.
      order(:name).page(params[:page])
  end

  def load_associations
    @countries = GeoEntity.joins(:geo_entity_type).
      where(
        'geo_entity_types.name' => [GeoEntityType::COUNTRY, GeoEntityType::TERRITORY],
        is_current: true
      ).
      order('name_en')
  end
end
