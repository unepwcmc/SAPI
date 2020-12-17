class PdfMerger
  def initialize(files, destination)
    @file_paths = files
    @destination = destination
  end

  def merge
    pdf_file_paths = @file_paths
    Prawn::Document.generate(@destination, {:page_size => 'A4', :skip_page_creation => true}) do |pdf|
      n = 0
      pdf_file_paths.each_slice(50) do |pdf_files|
       pdf_files.each do |pdf_file|
         n += 1
         puts "processing file n #{n} of #{pdf_file_paths.count} #{pdf_file.split('/').last}"
         pdf_temp_nb_pages = Prawn::Document.new(:template => pdf_file).page_count
         (1..pdf_temp_nb_pages).each do |i|
           pdf.start_new_page(:template => pdf_file, :template_page => i)
         end
       end
     end
    end
  end
end
