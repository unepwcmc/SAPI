class FooPdfFootnotes

  def initialize
    Prawn::Document.generate("foo_footnotes.pdf",:page_size => 'A4') do
      #read 150 lorem ipsum records of various length 
      records = File.read(Rails.root.join("lib/assets/lorem_ipsum_paragraphs.txt")).split("\n").reject(&:blank?)
      #assign some random footnotes to the paragraphs
      footnotes = {
        1 => '* ' + records[3],
        2 => '* ' + records[4],
      }
      footnotes_to_draw = []
      space_needed = 0
      for i in 0..records.length
        str = records[i]
        if footnotes.keys.include? i
          str += '*'#this one has a footnote attached
          space_needed += (height_of(footnotes[i]) + 15)
          footnotes_to_draw << footnotes[i]
        end
        text "#{str}"
        if space_needed > 0
          puts "space needed: #{space_needed}"
          space_available = cursor
          puts "space available: #{space_available}"
          unless space_available - space_needed > height_of(records[i+1])
            #it might be that we won't be able to fit the footer on same page
            if space_available < space_needed
              start_new_page
              redo
            else
              #hopefully we can draw the footer now
              puts "draw footer"
              bounding_box [0,space_needed], :width => bounds.width, :height => space_needed do
                stroke_horizontal_rule
                footnotes_to_draw.each do |footnote|
                  pad(10){text footnote}
                end
              end
              footnotes_to_draw = []
              space_needed = 0
              move_down space_needed
            end
          end
        end
      end
    end
  end

end