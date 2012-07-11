class FooPdf

  def initialize
    Prawn::Document.generate("foo.pdf",:page_size => 'A4') do
      zonks = ('zonk ' * 300).split
      zonk_footnotes = {10 => '* ' + "lalala " * 100, 70 => '* ' + "lololo " * 60}
      footnotes_to_draw = []
      space_needed = 0
      for i in 0..zonks.length
        str = zonks[i]
        if zonk_footnotes.keys.include? i
          str += '*'#this one has a footnote attached
          space_needed += height_of(zonk_footnotes[i])
          footnotes_to_draw << zonk_footnotes[i]
        end
        text "#{str}"
        if space_needed > 0
          puts "space needed: #{space_needed}"
          space_available = cursor
          puts "space available: #{space_available}"
          unless space_available - space_needed > 20#arbitrary mean space per zonk rekord
            #it might be that we won't be able to fit the footer on same page
            if space_available < space_needed
              start_new_page
              redo
            else
              #hopefully we can draw the footer now
              puts "draw footer"
              bounding_box [0,space_needed], :width => bounds.width, :height => space_needed do
                stroke_bounds
                footnotes_to_draw.each do |footnote|
                  text footnote
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