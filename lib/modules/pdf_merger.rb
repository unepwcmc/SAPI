class PdfMerger
  def initialize(files, destination)
    @file_paths = files
    @destination = destination
  end

  def merge
    pdf_file_paths = @file_paths
    Prawn::Document.generate(@destination, {:page_size => 'A4', :skip_page_creation => true}) do |pdf|
     pdf_file_paths.each do |pdf_file|
       pdf_temp_nb_pages = Prawn::Document.new(:template => pdf_file).page_count
       (1..pdf_temp_nb_pages).each do |i|
         pdf.start_new_page(:template => pdf_file, :template_page => i)
       end
     end
    end
  end
end
