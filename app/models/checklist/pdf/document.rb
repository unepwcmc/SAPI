module Checklist::Pdf::Document

  def ext
    'pdf'
  end

  def document
    # create directory for intermediate files
    tmp_dir_path = [Rails.root, "/tmp/", SecureRandom.hex(8)].join
    FileUtils.mkdir tmp_dir_path
    # copy the template to intermediate directory
    FileUtils.cp [Rails.root, "/public/latex/", 'index.tex'].join, tmp_dir_path
    @template_tex = [tmp_dir_path, '/index.tex'].join
    @tmp_tex    = [tmp_dir_path, '/_index.tex'].join
    # create the dynamic part
    File.open(@tmp_tex, "wb") do |tex|
      #tex << 'there goes dynamic content'
      yield tex
    end
    output = LatexToPdf.generate_pdf_from_file(tmp_dir_path, 'index')
    #save output at download path
    FileUtils.cp output, @download_path
  end

  def finalize
    FileUtils.rm_rf(tmp_dir_path)
  end

end
