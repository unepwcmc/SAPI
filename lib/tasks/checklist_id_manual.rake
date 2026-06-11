# Usage:
#   bundle exec rake checklist_id_manual:prebuild_and_upload_zips
#
# This task reads the local CITES ID manual volume PDFs from
# `public/ID_manual_volumes/<locale>/`, generates every non-empty volume
# combination as a ZIP archive, and uploads each archive to the same S3 bucket
# used by Active Storage under the `ID_manual_volumes/prebuilt_zip/` prefix.
#
# Important behaviour:
# - The filesystem is the source of truth for available locales and volumes.
# - Each ZIP is built in `tmp`, uploaded, then removed locally immediately.
# - Existing S3 objects are skipped, so reruns only upload missing artifacts.
#
namespace :checklist_id_manual do
  desc 'Prebuild every non-empty ZIP combination for the local ID manual volume PDFs'
  task prebuild_and_upload_zips: :environment do
    require 'aws-sdk-s3'
    require 'fileutils'
    require 'tempfile'
    require 'zip'

    source_root = Rails.root.join('public/ID_manual_volumes')

    unless source_root.directory?
      abort("Source directory does not exist: #{source_root}")
    end

    service_name = Rails.application.config.active_storage.service
    service_config = Rails.application.config.active_storage
      .service_configurations
      .fetch(service_name.to_s)
    service_type = service_config.fetch('service')

    unless service_type == 'S3'
      raise "checklist_id_manual:prebuild_and_upload_zips requires an S3-backed ActiveStorage service, got #{service_type.inspect}"
    end

    s3_client = Aws::S3::Client.new(
      access_key_id: service_config['access_key_id'],
      secret_access_key: service_config['secret_access_key'],
      session_token: service_config['session_token'],
      region: service_config['region'],
      endpoint: service_config['endpoint'],
      force_path_style: service_config['force_path_style']
    )
    bucket_name = service_config.fetch('bucket')
    key_prefix = 'ID_manual_volumes/prebuilt_zip'

    locale_dirs = Dir.children(source_root).filter_map do |entry|
      path = source_root.join(entry)

      # Only real locale directories are valid sources. This avoids treating
      # top-level ZIPs and helper folders as manual inputs.
      next unless path.directory?
      next if entry == 'prebuilt_zip'

      path
    end.sort_by(&:to_s)

    if locale_dirs.empty?
      abort("No locale directories found in #{source_root}")
    end

    locale_dirs.each do |locale_dir|
      locale = locale_dir.basename.to_s
      pdfs_by_volume = Dir.glob(locale_dir.join('*.pdf')).each_with_object({}) do |pdf_path, volumes|
        filename = File.basename(pdf_path)
        match = filename.match(/\AVolume(?<volume>\d+)_#{locale.upcase}\.pdf\z/)

        # The task intentionally derives combinations from the same filename
        # convention the controller expects, so unexpected files are ignored
        # rather than producing ambiguous ZIP names.
        next unless match

        volume = match[:volume].to_i
        volumes[volume] = Pathname.new(pdf_path)
      end

      volumes = pdfs_by_volume.keys.sort

      if volumes.empty?
        puts "Skipping #{locale}: no matching PDFs found"
        next
      end

      uploaded = 0

      volumes.length.times do |start_index|
        volumes.combination(start_index + 1) do |combination|
          filename = "Identifications-documents-volume-#{combination.join(',')}.zip"
          object_key = "#{key_prefix}/#{locale}/#{filename}"

          # The ZIP build is the expensive part, so we check S3 first and skip
          # any object that already exists under the deterministic key.
          begin
            s3_client.head_object(bucket: bucket_name, key: object_key)
            puts "Skipping existing s3://#{bucket_name}/#{object_key}"
            next
          rescue Aws::S3::Errors::NotFound
            # Expected when the object has not been uploaded yet.
          end

          zip_file = Tempfile.new([ "id-manual-volumes-", ".zip" ], Rails.root.join('tmp'))

          begin
            # The task uploads one artifact at a time and immediately removes
            # the local ZIP so disk usage stays flat even though the total
            # combination set is large.
            Zip::File.open(zip_file.path, create: true) do |zip|
              combination.each do |volume|
                pdf_path = pdfs_by_volume.fetch(volume)
                zip.add(pdf_path.basename.to_s, pdf_path.to_s)
              end
            end

            File.open(zip_file.path, 'rb') do |body|
              s3_client.put_object(
                bucket: bucket_name,
                key: object_key,
                body:
              )
            end

            uploaded += 1
            puts "Uploaded s3://#{bucket_name}/#{object_key}"
          ensure
            zip_file.close!
          end
        end
      end

      puts "Uploaded #{uploaded} ZIPs for #{locale} to s3://#{bucket_name}/#{key_prefix}/#{locale}/"
    end
  end
end
