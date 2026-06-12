class Checklist::DocumentsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    return render json: []  if params[:taxon_concepts_ids].nil?
    return render json: []  unless params[:taxon_concepts_ids].kind_of?(Array)

    anc_ids = MaterialDocIdsRetriever.ancestors_ids(params[:taxon_concepts_ids].first)
    chi_ids = MTaxonConcept.descendants_ids(params[:taxon_concepts_ids].first).map(&:to_i)
    params[:taxon_concepts_ids] = anc_ids | chi_ids
    @search = DocumentSearch.new(
      params.merge(show_private: !access_denied?, per_page: 10_000), 'public'
    )

    render json: @search.cached_results,
      each_serializer: Checklist::DocumentSerializer,
      meta: {
        total: @search.cached_total_cnt,
        page: @search.page,
        per_page: @search.per_page
      }
  end

  def show
    @document = Document.find(params[:id])

    if access_denied? && !@document.is_public
      render_403
    elsif @document.is_link?
      redirect_to @document.elib_legacy_file_name, allow_other_host: true
    elsif !@document.file.attached?
      render_404
    else
      # Redirect to S3 URL, which only valid for 1 minute (override Rails 7.1 default, which was 5 minutes)
      # WARNING: Don't use `rails_blob_url` for security reasons because it generates a permanent URL without requiring
      # authentication.
      redirect_to @document.file.url(disposition: 'attachment', expires_in: 1.minute), allow_other_host: true
    end
  end

  def check_doc_presence
    doc_ids = MaterialDocIdsRetriever.run(params.dup.permit!.to_h)

    render json: doc_ids.present?
  end

  ##
  # Redirects Checklist ID manual downloads to prebuilt ZIP artifacts produced
  # by the `checklist_id_manual:prebuild_and_upload_zips` rake task and stored
  # under `ID_manual_volumes/prebuilt_zip/<locale>/` in the Active Storage S3
  # bucket.
  def volume_download
    language_code = (params['locale'] || I18n.locale)&.to_s&.upcase
    raise ActiveRecord::RecordNotFound unless %w[EN ES FR].include?(language_code)

    volumes = Array.wrap(
      params['volume']
    ).map(&:to_i).filter(&:positive?).sort.uniq

    document_volumes = volumes.presence || [ 1, 2, 3, 4, 5, 6 ]
    raise ActiveRecord::RecordNotFound unless (document_volumes - [ 1, 2, 3, 4, 5, 6 ]).empty?

    filename = "Identifications-documents-volume-#{document_volumes.join(',')}.zip"
    object_key = "ID_manual_volumes/prebuilt_zip/#{language_code.downcase}/#{filename}"

    # The prebuilt ZIP bucket is now the source of truth for this endpoint, so
    # we fail with the same 404 path users already understand when the expected
    # artifact has not been uploaded yet.
    begin
      s3_client.head_object(bucket: s3_bucket_name, key: object_key)
    rescue Aws::S3::Errors::NotFound
      raise ActiveRecord::RecordNotFound
    end

    signed_url = s3_presigner.presigned_url(
      :get_object,
      bucket: s3_bucket_name,
      key: object_key,
      expires_in: 1.minute.to_i,
      response_content_disposition: %(attachment; filename="#{filename}")
    )

    redirect_to signed_url, allow_other_host: true
  end

private

  def active_storage_s3_config
    service_name = Rails.application.config.active_storage.service
    service_config = Rails.application.config.active_storage
      .service_configurations
      .fetch(service_name.to_s)

    raise 'Checklist::DocumentsController requires an S3-backed ActiveStorage service' unless service_config.fetch('service') == 'S3'

    service_config
  end

  def s3_bucket_name
    active_storage_s3_config.fetch('bucket')
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      access_key_id: active_storage_s3_config['access_key_id'],
      secret_access_key: active_storage_s3_config['secret_access_key'],
      session_token: active_storage_s3_config['session_token'],
      region: active_storage_s3_config['region'],
      endpoint: active_storage_s3_config['endpoint'],
      force_path_style: active_storage_s3_config['force_path_style']
    )
  end

  def s3_presigner
    @s3_presigner ||= Aws::S3::Presigner.new(client: s3_client)
  end

  def access_denied?
    !current_user || current_user.is_api_user_or_secretariat?
  end

  def render_404
    render file: "#{Rails.public_path.join('404.html')}",
      layout: false,
      formats: [ :html ],
      status: :not_found
  end

  def render_403
    render file: "#{Rails.public_path.join('403.html')}",
      layout: false,
      formats: [ :html ],
      status: :forbidden
  end
end
