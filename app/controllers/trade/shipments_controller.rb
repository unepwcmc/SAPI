class Trade::ShipmentsController < TradeController
  respond_to :json

  def index
    @search = Trade::Filter.new(search_params)
    render :json => @search.results,
      :each_serializer => Trade::ShipmentFromViewSerializer,
      :meta => metadata_for_search(@search)
  end

  def create
    @shipment = Trade::Shipment.new(shipment_params)
    if @shipment.save
      render :json => @shipment, :status => :ok
    else
      render :json => { "errors" => @shipment.errors }, :status => :unprocessable_entity
    end
  end

  def update
    @shipment = Trade::Shipment.find(params[:id])
    update_params = populate_accepted_taxon_concept(shipment_params)
    if @shipment.update_attributes(update_params)
      render :json => @shipment, :status => :ok
    else
      render :json => { "errors" => @shipment.errors }, :status => :unprocessable_entity
    end
  end

  def update_batch
    @batch_update = Trade::BatchUpdate.new(search_params)
    affected_rows = @batch_update.execute(
      populate_accepted_taxon_concept(batch_update_params)
    )
    render :json => { rows: affected_rows }, :status => :ok
  end

  def destroy
    @shipment = Trade::Shipment.find(params[:id])
    @shipment.destroy
    render :json => nil, :status => :ok
  end

  def destroy_batch
    @search = Trade::Filter.new(search_params)
    cnt = @search.query.count
    disconnected_permits_ids = @search.query.map do |s|
      s.permits_ids
    end.flatten.uniq
    @search.query.destroy_all
    PermitCleanupWorker.perform_async(disconnected_permits_ids)
    render :json => { rows: cnt }, :status => :ok
  end

  def accepted_taxa_for_reported_taxon_concept
    @resolver = Trade::ReportedTaxonConceptResolver.new(params[:reported_taxon_concept_id])
    render :json => @resolver.accepted_taxa,
      :each_serializer => Trade::TaxonConceptSerializer
  end

  private

  def shipment_attributes
    [
      :id,
      :appendix,
      :taxon_concept_id,
      :reported_taxon_concept_id,
      :term_id,
      :quantity,
      :unit_id,
      :importer_id,
      :exporter_id,
      :reporter_type,
      :country_of_origin_id,
      :purpose_id,
      :source_id,
      :year,
      :import_permit_number,
      :export_permit_number,
      :origin_permit_number
    ]
  end

  def shipment_params
    params.require(:shipment).permit(
      *(shipment_attributes + [
        :ignore_warnings
      ])
    )
  end

  def batch_update_params
    update_params = params.permit(
      :updates => shipment_attributes
    )
    res = update_params && update_params.delete('updates') || {}
    res.each { |k, v| res[k] = nil if v.blank? }
    reporter_type = res.delete(:reporter_type)
    unless reporter_type.blank?
      res[:reported_by_exporter] = Trade::Shipment.reporter_type_to_reported_by_exporter(reporter_type)
    end
    if res.key?(:import_permit_number) && res[:import_permit_number].nil?
      res[:import_permits_ids] = nil
    end
    if res.key?(:export_permit_number) && res[:export_permit_number].nil?
      res[:export_permits_ids] = nil
    end
    if res.key?(:origin_permit_number) && res[:origin_permit_number].nil?
      res[:origin_permits_ids] = nil
    end
    res
  end

  def populate_accepted_taxon_concept(update_params)
    if !update_params[:reported_taxon_concept_id].blank? && update_params[:taxon_concept_id].blank?
      # automatically resolve accepted taxon name
      accepted_tc = Trade::ReportedTaxonConceptResolver.new(
        update_params[:reported_taxon_concept_id]
      ).accepted_taxa.first
      update_params[:taxon_concept_id] = accepted_tc && accepted_tc.id
    end
    update_params
  end

end
