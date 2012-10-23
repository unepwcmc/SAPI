class Checklist::Json::History < Checklist::History
  include Checklist::Json::Document
  include Checklist::Json::HistoryContent

  def initialize(options={})
    @ext = 'json'
    super(options)
    @tmp_json    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.json'].join
  end

  def columns
    super + [:countries_iso_codes]
  end

  def column_values(rec)
    columns.map do |c|
      unless rec.respond_to? c
        send("column_value_for_#{c}", rec)
      else
        rec.send(c)
      end
    end
  end

  def column_value_for_countries_iso_codes(rec)
    rec.countries_ids.map do |id|
      Checklist::CountryDictionary.instance.getIsoCodeById(id)
    end
  end

end
