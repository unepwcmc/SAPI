class Admin::QuotasController < Admin::SimpleCrudController

  def duplication
    @years = Quota.select('EXTRACT(year from start_date) years').
      group(:years).order('years DESC').map(&:years)
    @count = Quota.where('EXTRACT(year from start_date) = ?', @years.first).
      count
    @geo_entities = GeoEntity.joins(:quotas).order(:name_en).uniq
  end

  def duplicate
    debugger
    true
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
        ",
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
  end
end
