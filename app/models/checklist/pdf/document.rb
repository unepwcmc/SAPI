module Checklist::Pdf::Document

  def ext
    'pdf'
  end

  def document
    # create directory for intermediate files
    tmp_dir_path = [Rails.root, "/tmp/", SecureRandom.hex(8)].join
    FileUtils.mkdir tmp_dir_path
    # copy the template to intermediate directory
    FileUtils.cp [Rails.root, "/public/latex/", "#{@input_name}.tex"].join,
      tmp_dir_path
    # copy the dictionary to intermediate directory
    FileUtils.copy_file [Rails.root, "/public/latex/", "_dict_#{I18n.locale}.tex"].join,
      [tmp_dir_path, '/_dict.tex'].join
    # set flags for latex
    flags_tex = [tmp_dir_path, "/_flags.tex"].join
    File.open(flags_tex, 'wb') do |tex|
      tex << (@intro ? "\\introtrue\n" : "\\introfalse\n")
    end

    @template_tex = [tmp_dir_path, "/#{@input_name}.tex"].join
    @tmp_tex    = [tmp_dir_path, "/_#{@input_name}.tex"].join
    # create the dynamic part
    File.open(@tmp_tex, "wb") do |tex|
      yield tex
    end
    output = LatexToPdf.generate_pdf_from_file(tmp_dir_path, @input_name)
    #save output at download path
    FileUtils.cp output, @download_path
    FileUtils.rm_rf(tmp_dir_path)
  end

end
