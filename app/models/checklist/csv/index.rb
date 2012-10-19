class Checklist::Csv::Index < Checklist::Index
  include Checklist::Csv::Document
  include Checklist::Csv::IndexContent

  def initialize(options={})
    super(options)
    @tmp_csv    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.csv'].join
  end

  def columns
    super + [:countries_iso_codes, :countries_full_names]
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

  def column_value_for_countries_full_names(rec)
    rec.countries_ids.map do |id|
      Checklist::CountryDictionary.instance.getNameById(id)
    end
  end

end
