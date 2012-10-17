class Checklist::Csv::IndexKingdom
  def initialize(csv, fetcher, kingdom_display_name)
    @csv = csv
    @fetcher = fetcher
    @kingdom_display_name = kingdom_display_name
    @columns = [:full_name, :rank_name, :family_name, :class_name,
    :cites_accepted, :current_listing,
    :specific_annotation_symbol, :generic_annotation_symbol,
    :english_names_ary, :spanish_names_ary, :french_names_ary]
  end

  def to_csv
    @csv << @columns
    begin
      #fetch data
      kingdom = @fetcher.next
      kingdom.each do |tc|
        entry = @columns.map{ |c| tc.send(c) }
        @csv << entry
      end
    end while not kingdom.empty?
  end
end