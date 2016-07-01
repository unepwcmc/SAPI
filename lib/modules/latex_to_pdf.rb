class LatexToPdf
  def self.config
    @config ||= {
      :command => 'pdflatex',
      :arguments => ['-halt-on-error'],
      :parse_twice => false
    }
  end

  # Runs pdflatex on a tex file.
  #
  # The dir argument is the name of the intermediate files directory.
  #
  # The input argument is the name of the tex file without the '.tex'
  def self.generate_pdf_from_file(dir, input)
    Process.waitpid(
      fork do
        begin
          Dir.chdir dir
          original_stdout, original_stderr = $stdout, $stderr
          $stderr = $stdout = File.open("#{input}.log", "a")
          args = config[:arguments] + %w[-shell-escape -interaction batchmode] + ["#{input}.tex"]
          exec config[:command], *args
        rescue
          File.open("#{input}.log", 'a') {|io|
            io.write("#{$!.message}:\n#{$!.backtrace.join("\n")}\n")
          }
        ensure
          $stdout, $stderr = original_stdout, original_stderr
          Process.exit! 1
        end
      end)
    if File.exist?(pdf_file = [dir, "/#{input}.pdf"].join)
      pdf_file
    else
      raise "pdflatex failed: See #{[dir, "/#{input}.log"].join} for details"
    end
  end

  # Escapes LaTex special characters in text so that they wont be interpreted as LaTex commands.
  #
  # This method will use RedCloth to do the escaping if available.
  def self.escape_latex(text)
    # :stopdoc:
    unless @latex_escaper
      if defined?(RedCloth::Formatters::LATEX)
        class << (@latex_escaper = RedCloth.new(''))
          include RedCloth::Formatters::LATEX
        end
      else
        class << (@latex_escaper = Object.new)
          ESCAPE_RE = /([{}_$&%#\r])|([\\^~|<>])/
          ESC_MAP = {
            '\\' => 'backslash',
            '^' => 'asciicircum',
            '~' => 'asciitilde',
            '|' => 'bar',
            '<' => 'less',
            '>' => 'greater'
          }

          def latex_esc(text) # :nodoc:
            text.gsub(ESCAPE_RE) {|m|
              if $1
                "\\#{m}"
              else
                "\\text#{ESC_MAP[m]}{}"
              end
            }
          end
        end
      end
      # :startdoc:
    end

    @latex_escaper.latex_esc(text.to_s) # .html_safe
  end

  def self.html2latex(text)
    return '' if text.blank?
    HtmlToLatex.convert(text)
  end

end
