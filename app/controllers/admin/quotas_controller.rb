class Admin::QuotasController < Admin::SimpleCrudController

  def duplication
    @years = Quota.select('EXTRACT(year from start_date) years').
      group(:years).order('years DESC').map(&:years)
    @count = Quota.where('EXTRACT(year from start_date) = ?', @years.first).
      count
    @geo_entities = GeoEntity.joins(:quotas).order(:name_en).uniq
  end

  def count
    @count = Quota.where([
        "EXTRACT(year from start_date) = :year
        #{ if params[:excluded_geo_entities].present?
           "AND geo_entity_id NOT IN (:excluded_geo_entities)"
          end}
        #{ if params[:included_geo_entities].present?
           "AND geo_entity_id IN (:included_geo_entities)"
          end}
        ",
        :year => params[:year],
        :excluded_geo_entities => params[:excluded_geo_entities],
        :included_geo_entities => params[:included_geo_entities]]).
        count
    render :json => @count.to_json
  end

  protected

  def collection
    @quotas ||= end_of_association_chain.order('start_date DESC').
      page(params[:page]).search(params[:query])
  end
end
