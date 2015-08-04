require 'fileutils'
# The purpose of this is to go over all document records and match them
# with respective files.
# Where files are present, create the expected directory structure, e.g.
# /private/elibrary/documents/1/filename
# Where files are missing, generate a report.
# source_dir is the path to the directory with flat file structure
# target dir is the path to the /private/elibrary
class Elibrary::DocumentFilesImporter
  def initialize(source_dir, target_dir)
    @source_dir = source_dir
    @target_dir = target_dir
  end

  def copy_with_path(src, dst)
    FileUtils.mkdir_p(File.dirname(dst))
    FileUtils.cp(src, dst)
  end

  def run
    total = Document.count
    Document.order(:type, :date).select([:id, :elib_legacy_file_name]).each_with_index do |doc, idx|
      info_txt = "#{doc.filename} (#{idx} of #{total})"
      target_location = @target_dir + "/documents/#{doc.id}/#{doc.elib_legacy_file_name}"
      # check if file exists at target location
      if File.exists?(target_location)
        puts "TARGET PRESENT #{target_location}" + info_txt
        next
      end
      source_location = @source_dir + "/#{doc.elib_legacy_file_name}"
      # check if file exists at source location
      unless File.exists?(source_location)
        puts "SOURCE MISSING #{source_location}" + info_txt
        next
      end
      copy_with_path(source_location, target_location)
      puts "COPIED " + info_txt
    end
  end
end
