require 'fileutils'
# The purpose of this is to go over all document records and match them
# with respective files.
# Where files are present, create the expected directory structure, e.g.
# /private/elibrary/documents/1/filename
# Where files are missing, generate a report.
# source_dir is the path to the directory with flat file structure
# target dir is the path to the /private/elibrary
class Elibrary::ManualDocumentFilesImporter
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
    identification_docs.each_with_index do |doc, idx|
      info_txt = "#{doc.elib_legacy_file_name} (#{idx + 1} of #{total})"
      target_location = @target_dir + "/documents/#{doc.id}/#{doc.elib_legacy_file_name}"
      # check if file exists at target location
      if File.exists?(target_location)
        puts "TARGET PRESENT #{target_location}" + info_txt
        next
      end
      source_location = @source_dir + "/#{doc.elib_legacy_file_name}"
      # check if file exists at source location
      unless File.exists?(source_location)
        case doc.type
        when 'Document::IdManual'
          puts "SOURCE MISSING #{source_location}" + info_txt
          next
        when 'Document::VirtualCollege'
          unless doc.elib_legacy_file_name =~ /\.pdf/
            puts "THIS IS A LINK TO EXTERNAL RESOURCES, NOT A PDF #{source_location}" + info_txt
          # else
            # remote_doc = Document.find(doc.id)
            # remote_doc.remote_filename_url = doc.elib_legacy_file_name
            # remote_doc.save!
          end
          puts "SOURCE MISSING #{source_location}" + info_txt
          next
        end
      end
      copy_with_path(source_location, target_location)
      puts "COPIED " + info_txt
    end
  end

  def identification_docs
    Document.where("type IN ('Document::IdManual', 'Document::VirtualCollege')")
            .order(:type, :date)
            .select([:id, :elib_legacy_file_name, :type])
  end
end
