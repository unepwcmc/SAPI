class ManualDownloadWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options retry: false, backtrace: 50

  def perform(download_id, params)
    @locale = params['locale']
    @download = Download.find(download_id)
    @download_path = download_location('zip', params)
    @display_name = params['taxon_name'] || MTaxonConcept.find(params['taxon_concept_id']).full_name

    unless File.exist?(@download_path.gsub('.pdf', '.zip'))
      doc_ids = MaterialDocIdsRetriever.run(params)
      @documents = Document.for_ids_with_order(doc_ids)

      zip_file_generator
    end

    @download.path     = [ Rails.root, '/public/downloads/checklist/', @filename, '.zip' ].join
    @download.filename = download_filename

    @download.display_name = @display_name # 'Id Manual resources'

    @download.status = 'completed'

    @download.save!
  rescue => exception
    Appsignal.add_exception(exception) if defined? Appsignal
    @download.status = 'failed'
    @download.save!
    raise exception
  end

private

  def download_filename
    ctime = File.ctime(@download.path).strftime('%Y-%m-%d %H:%M')
    @download_name = "ID_Materials-#{@display_name}-#{ctime}.zip"
  end

  def download_location(ext, params)
    require 'digest/sha1'

    @filename = Digest::SHA1.hexdigest(
      params.
      merge(format: ext).
      merge(type: 'citesidmanual').
      merge(locale: I18n.locale).
      to_hash.
      symbolize_keys!.
      sort.
      to_s
    )
    [ Rails.root, '/public/downloads/checklist/', @filename, '.', 'pdf' ].join
  end

  def zip_file_generator
    missing_files = []
    pdf_file_paths = []
    tmp_dir_path = [ Rails.root, '/tmp/', SecureRandom.hex(8) ].join
    zip_file_name = [
      Rails.root, '/public/downloads/checklist/', @filename, '.zip'
    ].join
    missing_file_name = [ tmp_dir_path, 'missing_files.txt' ].join

    FileUtils.mkdir tmp_dir_path

    input_name = 'merged_file.pdf'
    file_path = tmp_dir_path + '/' + input_name

    cover_path_generator

    pdf_file_paths << @cover_path

    @documents.each do |document|
      unless document.file.attached?
        # Note: this looks a bit like json. It's not. No idea why.
        missing_files <<
          "{\n  title: #{document.title},\n  filename: #{document.filename}\n}"
      else
        # Download the file from S3, put in temp folder.
        path_to_file = Rails.root.join(tmp_dir_path, document.file.filename.to_s).to_s
        File.open(path_to_file, "wb") do |out|
          # stream download in chunks
          document.file.blob.service.download(document.file.blob.key) do |chunk|
            out.write(chunk)
          end
        end

        pdf_file_paths << path_to_file
      end
    end

    begin
      PdfMerger.new(pdf_file_paths, file_path).merge

      FileUtils.cp file_path, @download_path

      Zip::File.open(zip_file_name, Zip::File::CREATE) do |zip|
        zip.add("Identification-materials-#{@display_name}.pdf", @download_path)

        if missing_files.present?
          File.write(missing_file_name, missing_files.join("\n\n"))
          zip.add('missing_files.txt', missing_file_name)
        end
      end
    ensure
      FileUtils.rm_rf(tmp_dir_path)
      FileUtils.rm_rf(@cover_path)
      FileUtils.rm(@download_path)
    end
  rescue => exception
    Appsignal.add_exception(exception) if defined? Appsignal
    @download.status = 'failed'
    @download.save!
    raise exception
  end

  def cover_path_generator
    I18n.locale = @locale

    kit = PDFKit.new(
      ActionController::Base.new().render_to_string(
        template: '/checklist/_custom_id_manual_cover',
        locals: { taxon_name: @display_name }
      ),
      page_size: 'A4',
      enable_local_file_access: true
    )

    kit.stylesheets << "#{Rails.root.join("app/assets/stylesheets/checklist/custom_id_manual_cover.css")}"

    @cover_path = "public/downloads/checklist/#{@display_name}-cover.pdf"

    kit.to_file(@cover_path)
  end
end
