class Api::V1::DocumentsController < ApplicationController
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
            children.pluck(:id) if children.present?
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
        show_private: !access_denied?,
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

  def download_zip
    @documents = Document.find(params[:ids].split(','))

    t = Tempfile.new('tmp-zip-' + request.remote_ip)

    missing_files = []

    Zip::OutputStream.open(t.path) do |zos|
      @documents.each do |document|
        unless document.file.attached?
          missing_files <<
            "{\n  title: #{document.title},\n  filename: #{document.filename}\n}"
        else
          zos.put_next_entry(document.file.filename)
          ActiveStorage::Blob.service.download(document.file.blob.key) do |chunk|
            zos.print(chunk)
          end
        end
      end

      if missing_files.present?
        if missing_files.length == @documents.count
          render_404 && return
        end

        zos.put_next_entry('missing_files.txt')
        zos.print missing_files.join("\n\n")
      end
    end

    send_file t.path,
      type: 'application/zip',
      filename: 'elibrary-documents.zip'

    t.close
  end

private

  def access_denied?
    !current_user || current_user.is_api_user_or_secretariat?
  end

  def render_404
    head :not_found
  end

  def render_403
    head :forbidden
  end
end
