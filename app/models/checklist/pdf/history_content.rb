module Checklist::Pdf::HistoryContent

  def content(pdf)
    fetcher = Checklist::Pdf::HistoryFetcher.new(@animalia_rel)
    kingdom(pdf, fetcher, 'FAUNA')
    fetcher = Checklist::Pdf::HistoryFetcher.new(@plantae_rel)
    kingdom(pdf, fetcher, 'FLORA')
  end

  def kingdom(pdf, fetcher, kingdom_name)
    pdf.text(kingdom_name, :size => 12, :align => :center)
    begin
      #fetch data
      kingdom = fetcher.next
      listings_table = []
      kingdom.each do |tc|
        #puts "#{(tc.kind_of?(Checklist::HigherTaxaItem) ? 'H' : '')} #{tc.full_name}"
        unless listings_table.blank?
          pdf.table(listings_table,
            :column_widths => {0 => 142},
            :cell_style => {:borders => [], :padding => [1,0,1,0]}
          )
          listings_table = []
        end
        if tc.kind_of? Checklist::HigherTaxaItem
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
        else
          listings_subtable = pdf.make_table(tc.listing_changes.map do |lh|
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
              "#{[lh.english_full_note, lh.spanish_full_note, lh.french_full_note].compact.join("\n")}".gsub(/NULL/,'')
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