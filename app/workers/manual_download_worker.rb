class ManualDownloadWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options :retry => false, :backtrace => 50

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

    @download.path     = [Rails.root, '/public/downloads/checklist/', @filename , '.zip'].join
    @download.filename = download_filename

    @download.display_name = @display_name # 'Id Manual resources'

    @download.status = "completed"

    @download.save!
  rescue => exception
    Appsignal.add_exception(exception) if defined? Appsignal
    @download.status = "failed"
    @download.save!
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
    return [Rails.root, '/public/downloads/checklist/', @filename, '.', 'pdf'].join
  end

  def zip_file_generator
    require 'zip'

    missing_files = []
    pdf_file_paths = []
    tmp_dir_path = [Rails.root, "/tmp/", SecureRandom.hex(8)].join
    FileUtils.mkdir tmp_dir_path
    input_name = 'merged_file.pdf'
    file_path = tmp_dir_path + '/' + input_name
    cover_path_generator
    pdf_file_paths << @cover_path
    @documents.each do |document|
      path_to_file = document.filename.path
      filename = path_to_file.split('/').last
      unless File.exists?(path_to_file)
        missing_files <<
          "{\n  title: #{document.title},\n  filename: #{filename}\n}"
      else
        pdf_file_paths << path_to_file
      end
    end
    PdfMerger.new(pdf_file_paths, file_path).merge

    FileUtils.cp file_path, @download_path
    FileUtils.rm_rf(tmp_dir_path)
    FileUtils.rm_rf(@cover_path)

    Zip::File.open([Rails.root, '/public/downloads/checklist/', @filename , '.zip'].join, Zip::File::CREATE) do |zip|
      zip.add("Identification-materials-#{@display_name}.pdf", @download_path)
      if missing_files.present?
        zip.add('missing_files.txt', missing_files.join("\n\n"))
      end
    end
    FileUtils.rm(@download_path)
  rescue => exception
    Appsignal.add_exception(exception) if defined? Appsignal
    @download.status = "failed"
    @download.save!
  end

  def cover_path_generator
    I18n.locale = @locale
    kit = PDFKit.new(ActionController::Base.new().render_to_string(template: '/checklist/_custom_id_manual_cover.html.erb', locals: { taxon_name: @display_name }), page_size: 'A4')
    kit.stylesheets << "#{Rails.root.to_s}/app/assets/stylesheets/checklist/custom_id_manual_cover.css"
    @cover_path = "public/downloads/checklist/#{@display_name}-cover.pdf"
    kit.to_file(@cover_path)
  end
end
