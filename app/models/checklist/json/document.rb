module Checklist::Json::Document

  def document
    File.open(@tmp_json, "wb") do |json|
      yield json
    end

    @download_path = @tmp_json
  end

end