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
      if user_params[:password].blank?
        @user.update_without_password(user_params)
      else
        @user.update_attributes(user_params) # TODO: `update_attributes` is deprecated in Rails 6, and removed from Rails 7.
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

  private

  def user_params
    params.require(:user).permit(
      :email, :name, :password, :password_confirmation,
      :remember_me, :role, :terms_and_conditions, :is_cites_authority,
      :organisation, :geo_entity_id, :is_active
    )
  end
end
