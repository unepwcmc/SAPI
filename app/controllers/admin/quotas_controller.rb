class Admin::QuotasController < Admin::SimpleCrudController

  def index
    @years = Quota.select('EXTRACT(year from start_date) years').
      group(:years).order('years DESC').map(&:years)
    index!
  end

  def duplication
    @years = Quota.select('EXTRACT(year from start_date) years').
      group(:years).order('years DESC').map(&:years)
    @count = Quota.where('EXTRACT(year from start_date) = ?', @years.first).
      count
    @geo_entities = GeoEntity.joins(:quotas).order(:name_en).uniq
  end

  def duplicate
    QuotasCopyWorker.perform_async(params[:quotas])
    redirect_to admin_quotas_path, :notice => "Your quotas are being duplicated in the background.
      They will show in this page in a few seconds"
  end

  def count
    @count = Quota.where([
        "EXTRACT(year from start_date) = :year
        #{ if params[:excluded_geo_entities_ids].present?
           "AND geo_entity_id NOT IN (:excluded_geo_entities)"
          end}
        #{ if params[:included_geo_entities_ids].present?
           "AND geo_entity_id IN (:included_geo_entities)"
          end}
        #{ if params[:excluded_taxon_concepts_ids].present?
           "AND taxon_concept_id NOT IN (:excluded_taxon_concepts)"
          end}
        #{ if params[:included_taxon_concepts_ids].present?
           "AND taxon_concept_id IN (:included_taxon_concepts)"
          end}
        AND is_current = true",
        :year => params[:year],
        :excluded_geo_entities => params[:excluded_geo_entities_ids],
        :included_geo_entities => params[:included_geo_entities_ids],
        :excluded_taxon_concepts => params[:excluded_taxon_concepts_ids],
        :included_taxon_concepts => params[:included_taxon_concepts_ids]]).
        count
    render :json => @count.to_json
  end

  protected

  def collection
    @quotas ||= end_of_association_chain.order('start_date DESC').
      page(params[:page]).search(params[:query])
    return @quotas if !params[:year]
    @quotas = @quotas.where('EXTRACT(year from start_date) = ?', params[:year])
  end
end
