class Checklist::Csv::History < Checklist::History
  include Checklist::Csv::Document
  include Checklist::Csv::HistoryContent

  def initialize(options={})
    @ext = 'csv'

    super(options)
  end

  def columns
    res = super
    split = res.index(:party_name)
    res = res[0..split] + [:party_full_name] + res[split+1..res.length-1]
    res += [:countries_iso_codes, :countries_full_names]
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

  def column_value_for_party_full_name(rec)
    Checklist::CountryDictionary.instance.getNameById(rec.party_id)
  end

  def column_value_for_countries_iso_codes(rec)
    rec.countries_ids.map do |id|
      Checklist::CountryDictionary.instance.getIsoCodeById(id)
    end
  end

  def column_value_for_countries_full_names(rec)
    rec.countries_ids.map do |id|
      Checklist::CountryDictionary.instance.getNameById(id)
    end
  end

end
