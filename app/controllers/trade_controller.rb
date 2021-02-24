class TradeController < ApplicationController

  before_filter :authenticate_user!
  before_filter :verify_manager_or_secretariat_or_active, except: [:update, :create, :submit, :destroy]
  before_filter :verify_manager, only: [:update, :create, :submit, :destroy, :update_batch, :destroy_batch]

  def user_can_edit
    render json: { can_edit: current_user.is_manager? && current_user.is_active? }
  end

  private

  def verify_manager_or_secretariat_or_active
    unless current_user.is_manager_or_secretariat? || current_user.is_active
      redirect_to signed_in_root_path(current_user)
    end
  end

  def verify_manager
    raise CanCan::AccessDenied unless current_user.is_manager?
  end

  def search_params
    (params[:filters] || params).permit(
      :reporter_type,
      :time_range_start,
      :time_range_end,
      :quantity,
      :unit_blank,
      :purpose_blank,
      :source_blank,
      :country_of_origin_blank,
      :permit_blank,
      :report_type,
      :internal,
      :page,
      :csv_separator,
      taxon_concepts_ids: [], #For downloads needs to be array, but not for search... make array in custom transition?Or is this mapped away from array in ruby!?!!!?!?!?!?!?!
      reported_taxon_concepts_ids: [],
      appendices: [],
      terms_ids: [],
      units_ids: [],
      purposes_ids: [],
      sources_ids: [],
      importers_ids: [],
      exporters_ids: [],
      countries_of_origin_ids: [],
      permits_ids: [],
    ).merge(params_overrides)
  end

  def params_overrides
    {
      internal: true,
      # always search descendants
      taxon_with_descendants: true,
      report_type:
        if params[:filters] && params[:filters][:report_type] &&
          Trade::ShipmentsExportFactory.report_types &
          [report_type = params[:filters][:report_type].downcase.strip.to_sym]
          report_type
        else
          :raw
        end,
      csv_separator:
        if params[:filters] && params[:filters][:csv_separator] &&
          params[:filters][:csv_separator].downcase.strip.to_sym == :semicolon
          :semicolon
        else
          :comma
        end
    }
  end
end
