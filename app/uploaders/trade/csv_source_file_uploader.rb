# encoding: utf-8
require 'fileutils'

class Trade::CsvSourceFileUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  process :convert_to_utf8
  process :remove_blank_lines

  def remove_blank_lines
    cache_stored_file! if !cached?
    directory = File.dirname(current_path)
    tmp_path = File.join(directory, "tmpfile")
    if system("cat #{current_path} | sed 's/\r//g' | grep -v -E '^(\"?[[:blank:]]*\"?,)*$' > #{tmp_path}")
      FileUtils.mv(tmp_path, current_path)
    else
      Rails.logger.error("#{$!}")
    end
  end

  def convert_to_utf8
    content = File.read(current_path)
    begin
      # Try it as UTF-8 directly
      cleaned = content.dup.force_encoding('UTF-8')
      unless cleaned.valid_encoding?
        cleaned = content.encode('UTF-8', 'iso-8859-1')
      end
      content = cleaned
    rescue EncodingError
      # Force it to UTF-8, throwing out invalid bits
      content.encode!('UTF-8', invalid: :replace, undef: :replace)
    end
    File.open(current_path, 'w') { |file| file.write(content) }
  end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(csv)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
