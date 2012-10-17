class Checklist::Csv::HistoryKingdom
  def initialize(csv, fetcher, kingdom_display_name)
    @csv = csv
    @fetcher = fetcher
    @kingdom_display_name = kingdom_display_name
    @columns = [:taxon_concept_id, :change_type_name, :species_listing_name, :effective_at, :party_name]
  end

  def to_csv
    @csv << @columns
    begin
      #fetch data
      puts 'fetch'
      kingdom = @fetcher.next
      puts 'process'
      kingdom.each do |tc|
        entry = @columns.map{ |c| tc.send(c) }
        @csv << entry
      end
      puts 'done'
    end while not kingdom.empty?
  end
end