module Checklist::Json::Document

  def ext
    'json'
  end

  def document
    @tmp_json    = [Rails.root, "/tmp/", SecureRandom.hex(8), ".#{ext}"].join
    File.open(@tmp_json, "wb") do |json|
      yield json
    end

    @download_path = @tmp_json
  end

end