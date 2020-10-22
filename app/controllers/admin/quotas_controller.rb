class Admin::QuotasController < Admin::StandardAuthorizationController

  def index
    @years = Quota.years_array
    if params[:year] && !@years.include?(params[:year])
      @years = @years.push(params[:year]).sort { |a, b| b <=> a }
    end
    index!
  end

  def duplication
    @years = Quota.years_array
    @count = Quota.where('EXTRACT(year from start_date)::VARCHAR = ? AND is_current = true', @years.first).
      count
    @geo_entities = GeoEntity.joins(:quotas).order(:name_en).uniq
  end

  def duplicate
    quota_params = params[:quotas].merge(:current_user_id => current_user.id)
    QuotasCopyWorker.perform_async(quota_params)
    redirect_to admin_quotas_path({ :year => params[:quotas][:start_date].split("/")[2] }),
      :notice => "Your quotas are being duplicated in the background.
      They will be available from this page in a few seconds (please refresh it)"
  end

  def count
    @count = Quota.count_matching params
    render :json => @count.to_json
  end

  protected

  def collection
    @quotas ||= end_of_association_chain.order('start_date DESC').
      page(params[:page]).search(params[:query])
    return @quotas if !params[:year]
    @quotas = @quotas.where('EXTRACT(year from start_date)::INTEGER = ?', params[:year].to_i)
  end
end
