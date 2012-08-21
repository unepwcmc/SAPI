class FooPdfIndents

  def initialize
    Prawn::Document.generate("foo_indents.pdf",:page_size => 'A4') do
      records = File.read(Rails.root.join("lib/assets/lorem_ipsum_paragraphs.txt")).split("\n").reject(&:blank?)
      column_box([0, cursor], :columns => 3, :width => bounds.width) do
        records.each { |r| text r, :indent_paragraphs => 20 }
      end
    end
  end

end