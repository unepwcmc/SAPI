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
  # @params String filesystem locations of PDFs
  # @returns String PDF data to be streamed
  def merge_pdfs(file, *args)
    # Check Pdftk is on the PATH
    `which pdftk`
    raise 'Pdftk is not installed'  unless $?.success?

    puts `pdftk #{args.join(' ')} output #{file}`
    puts "merged into #{file}"
  end

  # Atatches any number of PDFs using the PDFTK library
  #
  # @params String filesystem locations of PDFs
  def attach_pdfs(file, master, *args)
    # Check Pdftk is on the PATH
    `which pdftk`
    raise 'Pdftk is not installed'  unless $?.success?

    puts `pdftk #{master} attach_files #{args.join(' ')} output #{file}`
    puts "attached into #{file}"
  end

end
