class Checklist::Csv::Index < Checklist::Index
  include Checklist::Csv::Document
  include Checklist::Csv::IndexContent

  def initialize(options={})
    super(options)
    @tmp_csv    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.csv'].join
  end

  def columns
    super + [:countries_iso_codes, :countries_full_names,
      :generic_english_full_note, :generic_spanish_full_note,
      :generic_french_full_note,
      :english_full_note, :spanish_full_note, :french_full_note
    ]
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

  ['English', 'Spanish', 'French'].each do |lng|
    define_method("column_value_for_generic_#{lng.downcase}_full_note") do |rec|
      rec.current_m_listing_changes.map do |lc|
        note = lc.send("generic_#{lng.downcase}_full_note")
        if note
          "Appendix #{lc.species_listing_name}:" + note
        else
          ''
        end
      end.join("\n")
    end

    define_method("column_value_for_#{lng.downcase}_full_note") do |rec|
      rec.current_m_listing_changes.map do |lc|
        note = lc.send("#{lng.downcase}_full_note")
        if note
          "Appendix #{lc.species_listing_name}:" + note
        else
          ''
        end
      end.join("\n")
    end
  end

end
