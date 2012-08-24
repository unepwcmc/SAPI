# Supplies a number of custom PDF helpers for use in models
module PDF

  # Returns the number of pages in a given PDF file
  #
  # @params String filesystem locations of PDFs
  # @returns Fixnum page count
  def get_page_count(filename)
    reader = PDF::Reader.new(filename)

    reader.page_count
  end

  # Merges any number of PDFs using the PDFTK library
  #
  # Cleans up generated files only, passed PDFs must be removed
  # elsewhere
  #
  # @params String filesystem locations of PDFs
  # @returns String PDF data to be streamed
  def merge_pdfs(*args)
    # Check Pdftk is on the PATH
    `which pdftk`
    raise 'Pdftk is not installed'  unless $?.success?

    combined_pdf_index = [Rails.root, '/tmp/comb-', SecureRandom.hex(8), '.pdf'].join
    puts `pdftk #{args.join(' ')} output #{combined_pdf_index}`
    puts "merged into #{combined_pdf_index}"
    combined_pdf_index
  end

  # Atatches any number of PDFs using the PDFTK library
  #
  # Cleans up generated files only, passed PDFs must be removed
  # elsewhere
  #
  # @params String filesystem locations of PDFs
  # @returns String PDF data to be streamed
  def attach_pdfs(master, *args)
    # Check Pdftk is on the PATH
    `which pdftk`
    raise 'Pdftk is not installed'  unless $?.success?

    combined_pdf_index = [Rails.root, '/tmp/comb-', SecureRandom.hex(8), '.pdf'].join
    puts `pdftk #{master} attach_files #{args.join(' ')} output #{combined_pdf_index}`
    puts "attached into #{combined_pdf_index}"
    combined_pdf_index
  end

end
