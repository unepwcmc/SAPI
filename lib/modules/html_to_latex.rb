# Poor man's implementation. Don't event want to say more.
# Reason for this: pandoc was either extremely slow or hanging.
class HtmlToLatex

  def self.convert(input_str)
    doc = Nokogiri::HTML(input_str)
    output_str = ''
    doc.at_css("body").traverse do |n|
      if n.text?
        n_content = LatexToPdf.escape_latex(n.content)
        if n.parent.name == 'i'
          output_str << "\\textit{#{n_content}}"
        elsif n.parent.name == 'b'
          output_str << "\\textbf{#{n_content}}"
        else
          output_str << n_content
          if n.parent.name == 'p' && n.next_sibling.nil?
            output_str << "\n\n"
          end
        end
      end
    end
    output_str
  end

end