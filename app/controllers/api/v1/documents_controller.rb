class Api::V1::DocumentsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    @all_taxon_concepts_ids = []
    @taxon_concepts_ids = []

    if params[:taxon_concept_query].present?
      exact_match =
        MTaxonConcept.where(
          'upper(full_name) = ?', params[:taxon_concept_query].upcase
        ).where(
          taxonomy_id: 1
        ).first

      @species_search = Species::Search.new(
        {
          visibility: :elibrary,
          taxon_concept_query: params[:taxon_concept_query]
        }
      )

      @taxon_concepts_ids = @species_search.ids

      anc_ids =
        if exact_match
          MaterialDocIdsRetriever.ancestors_ids(
            exact_match.try(:id), params[:taxon_concept_query], exact_match
          )
        else
          []
        end

      children_ids =
        if exact_match
          MTaxonConcept.descendants_ids(
            exact_match.try(:id)
          ).map(&:to_i)
        else
          []
        end

      @all_taxon_concepts_ids = @taxon_concepts_ids | anc_ids | children_ids
    else
      if params[:taxon_concepts_ids].present?
        taxa = TaxonConcept.find(params[:taxon_concepts_ids])

        @taxon_concepts_ids = taxa.map(&:id)

        children_ids =
          taxa.map(&:children).map do |children|
            children.presence&.pluck(:id)
          end.flatten.uniq.compact

        ancestor_ids = MaterialDocIdsRetriever.ancestors_ids(
          @taxon_concepts_ids.first
        )

        @all_taxon_concepts_ids = @taxon_concepts_ids | ancestor_ids | children_ids
      end
    end

    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 100).to_i

    @search = DocumentSearch.new(
      params.merge(
        taxon_concepts_ids: @all_taxon_concepts_ids,
        show_private: can_see_private_documents?,
        page: page,
        per_page: per_page,
      ),
      'public'
    )

    render json: @search.cached_results,
      each_serializer: Species::DocumentSerializer,
      meta: {
        total: @search.cached_total_cnt,
        page: @search.page,
        per_page: per_page
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

  # This API variant is triggered by the Species+ frontend from
  # `app/assets/javascripts/species/views/documents/batch_download_component.js.coffee`
  # on both:
  # - `/#/documents`
  # - `/#/taxon_concepts/:taxon_concept_id/documents`
  def download_zip
    id_strings = params[:ids].to_s.split(',')
    ids = id_strings.map(&:to_i).reject(&:zero?).uniq

    return head :unprocessable_entity if ids.empty?

    @documents = accessible_documents.find(ids)

    return render_404 if ids.length > @documents.count

    # If there are missing files, we will generate a zip file with an additional
    # file called `missing_files.txt`. But if all files are missing, then we can
    # just return a 404 here.
    return render_404 unless
      @documents.any? do |document|
        document.file.attached?
      end

    # We key `DownloadZip` records by a deterministic checksum so identical
    # document selections converge on the same asynchronous ZIP request instead
    # of queuing duplicate work. Sorting by document ID removes frontend
    # selection-order noise, and including missing-file metadata keeps the
    # checksum aligned with the old ZIP contract, which added
    # `missing_files.txt` when some selected files were unavailable.
    checksum = documents_zip_checksum(@documents)
    document_ids = @documents.map(&:id).sort

    download_zip =
      DownloadZip.create_or_find_by!(checksum:) do |record|
        record.document_ids = document_ids
      end

    render json: download_zip_response(download_zip), status: :accepted
  end

  # old version for reference.
  # def download_zip
  #   @documents = Document.find(params[:ids].split(','))

  #   t = Tempfile.new('tmp-zip-' + request.remote_ip)

  #   missing_files = []

  #   Zip::OutputStream.open(t.path) do |zos|
  #     @documents.each do |document|
  #       unless document.file.attached?
  #         missing_files <<
  #           "{\n  title: #{document.title},\n  filename: #{document.filename}\n}"
  #       else
  #         zos.put_next_entry(document.file.filename)
  #         ActiveStorage::Blob.service.download(document.file.blob.key) do |chunk|
  #           zos.print(chunk)
  #         end
  #       end
  #     end

  #     if missing_files.present?
  #       if missing_files.length == @documents.count
  #         render_404 && return
  #       end

  #       zos.put_next_entry('missing_files.txt')
  #       zos.print missing_files.join("\n\n")
  #     end
  #   end

  #   send_file t.path,
  #     type: 'application/zip',
  #     filename: 'elibrary-documents.zip'

  #   t.close
  # end

private

  # All documents are public except SRG documents
  #
  # These should only be visible to:
  #
  # a) the e-Library users (those involved in the EU SRG process)
  # b) Platform Managers (WCMC staff)
  #
  # There is no reason for CITES Secretariat members to have this access.
  #
  # People who sign up via the API site definitely don't have this access.
  def can_see_private_documents?
    current_user && (
      current_user.is_elibrary_user? ||
      current_user.is_manager?
    )
  end

  def accessible_documents
    if can_see_private_documents?
      Document.all
    else
      Document.where(is_public: true)
    end
  end

  def render_404
    head :not_found
  end

  def render_403
    head :forbidden
  end

  def documents_zip_checksum(documents)
    checksum_input =
      documents.sort_by(&:id).map do |document|
        if document.file.attached?
          blob = document.file.blob

          [
            document.id,
            blob.id,
            blob.filename.to_s,
            blob.byte_size,
            blob.checksum
          ].join(':')
        else
          [
            document.id,
            document.title,
            document.filename,
            'missing'
          ].join(':')
        end
      end

    Digest::SHA256.hexdigest(checksum_input.join("\n"))
  end

  def download_zip_response(download_zip)
    {
      id: download_zip.id,
      status: download_zip.status,
      error_message: download_zip.error_message,
      processing_at: download_zip.processing_at,
      completed_at: download_zip.completed_at,
      download_url: download_zip_download_url(download_zip)
    }
  end

  def download_zip_download_url(download_zip)
    return unless download_zip.status == DownloadZip::COMPLETED
    return unless download_zip.zip_file.attached?

    # Signed URLs should stay short-lived because they grant direct access to
    # the generated ZIP in storage without another application authorization
    # check. Matching the existing document download expiry keeps this flow
    # consistent with the rest of the API.
    download_zip.zip_file.url(disposition: 'attachment', expires_in: 1.minute)
  end
end
