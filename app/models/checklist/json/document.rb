module Checklist::Json::Document

  def ext
    'json'
  end

  def document
    File.open(@download_path, "wb") do |json|
      yield json
    end

    @download_path
  end

end