class Checklist::PdfHistoryKingdom
  def initialize(pdf, rel, kingdom_display_name)
    @pdf = pdf
    @rel = rel
    @kingdom_display_name = kingdom_display_name
  end

  def to_pdf
    pdf = @pdf
    limit = 5000
    offset = 0
    pdf.text(@kingdom_display_name, :size => 12, :align => :center)

    @indent = 15
    pdf.column_box([0, pdf.cursor], :columns => 2, :width => pdf.bounds.width) do

    begin
      #fetch data
      kingdom = @rel.limit(limit).offset(offset).all
      offset += limit
      listings_table = []
      kingdom.each do |tc|
        unless listings_table.blank?
          pdf.table(listings_table,
            :column_widths => {0 => 142},
            :cell_style => {:borders => [], :padding => [1,0,1,0]}
          )
          listings_table = []
        end

        if tc.rank_name == 'PHYLUM'
          pdf.text "<b>#{tc.full_name.upcase}</b>",
            :size => 16,
            :align => :center,
            :inline_format => true
        elsif tc.rank_name == 'CLASS'
          pdf.pad(20){
            pdf.text "<b><u>#{tc.full_name.upcase}</u></b>",
            :size => 12,
            :inline_format => true
          }
        elsif ['ORDER','FAMILY'].include? tc.rank_name
          pdf.pad(10){
              pdf.formatted_text [
              {
                :text => tc.full_name.upcase,
                :styles => [:bold],
                :size => 10
              },
              {
                :text =>
                (tc.english_names_list.blank? ? '' : "(E) #{tc.english_names_list} ") },
              {
                :text =>
                (tc.spanish_names_list.blank? ? '' : "(S) #{tc.spanish_names_list} ") },
              {
                :text =>
                (tc.french_names_list.blank? ? '' : "(F) #{tc.french_names_list} ") }
            ]
          }
        end
        unless tc.kind_of? Checklist::HigherTaxaItem
          #filter out null records for higher taxa
          listings_subtable = pdf.make_table(tc.m_listing_changes.map do |lh|
            [
              "#{lh.species_listing_name}#{
                if lh.change_type_name == ChangeType::RESERVATION
                  '/r'
                elsif lh.change_type_name == ChangeType::RESERVATION_WITHDRAWAL
                  '/w'
                elsif lh.change_type_name == ChangeType::DELETION
                  'Del'
                else
                  nil
                end
              }",
              "#{lh.party_name}".upcase,
              "#{lh.effective_at ? lh.effective_at.strftime("%d/%m/%y") : nil}",
              'TODO note + footnote'
              #"#{[lh.english_full_note, lh.spanish_full_note, lh.french_full_note].compact.join("\n")[0..100]}".gsub(/NULL/,'')
            ]
          end,
            {
              :column_widths => [27, 24, 45, 243],
              :cell_style => {:borders => [], :padding => [1,0,1,0]}
            }
          )

          listings_table << [
            pdf.make_cell(:content => "<i>#{tc.full_name}</i>", :inline_format => true),
            listings_subtable
          ]
        end
      end
      end while not kingdom.empty?
    end
  end
end