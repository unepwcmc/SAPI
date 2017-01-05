class Trade::AnnualReportUploadsController < TradeController
  respond_to :json

  def index
    @annual_report_uploads = Trade::AnnualReportUpload.created_by_sapi
    if params[:is_done].present?
      null_cond = if params[:submitted] == 1
        'submitted_at IS NOT NULL'
      else
        'submitted_at IS NULL'
      end
      @annual_report_uploads = @annual_report_uploads.where(
        null_cond
      )
    end
    render :json => @annual_report_uploads,
      :each_serializer => Trade::AnnualReportUploadSerializer
  end

  def show
    render :json => Trade::AnnualReportUpload.find(params[:id]),
      :serializer => Trade::ShowAnnualReportUploadSerializer
  end

  def create
    @annual_report_upload = Trade::AnnualReportUpload.create(
      annual_report_upload_params
    )
    render :json => { :files => [@annual_report_upload.to_jq_upload] }
  end

  def submit
    @annual_report_upload = Trade::AnnualReportUpload.find(params[:id])
    if @annual_report_upload.submit(current_user)
      render :json => @annual_report_upload, :status => :ok,
        :serializer => Trade::ShowAnnualReportUploadSerializer
    else
      render :json => { "errors" => @annual_report_upload.errors },
        :status => :unprocessable_entity
    end
  end

  def destroy
    @annual_report_upload = Trade::AnnualReportUpload.find(params[:id])
    unless @annual_report_upload.submitted_at.present?
      @annual_report_upload.destroy
      render :json => nil, :status => :ok
    else
      head 403
    end
  end

  private

  def annual_report_upload_params
    params.require(:annual_report_upload).permit(
      :csv_source_file, :trading_country_id, :point_of_view,
      :sandbox_shipments => [
        :id,
        :appendix,
        :taxon_name,
        :term_code,
        :quantity,
        :unit_code,
        :trading_partner,
        :country_of_origin,
        :import_permit,
        :export_permit,
        :origin_permit,
        :purpose_code,
        :source_code,
        :year,
        :_destroyed
      ]
    )
  end

end
