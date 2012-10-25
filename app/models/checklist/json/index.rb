class Checklist::Json::Index < Checklist::Index
  include Checklist::Json::Document
  include Checklist::Json::IndexContent

  def initialize(options)
    super(options)
    @json_options = json_options
  end

  def json_options
    json_options = super
    #just the simple set for the index
    json_options.delete(:include)
    json_options[:methods] = [:countries_iso_codes]#TODO
    json_options
  end

  #TODO
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
