Apipie.configure do |config|
  config.app_name = "CITES Checklist and Species+ API"
  config.api_base_url = "/api/v2"
  config.doc_base_url = "/apipie"
  config.default_version = "2.0"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v2/*.rb"

  config.app_info = <<-EOS
      ==== Purpose of this API
      Application Programming Interface (API) to support CITES Parties
      to increase the accuracy and efficiency of curating CITES species data for permitting purposes.
    EOS
  config.copyright = "&copy; #{Time.now.year} UNEP-WCMC"
end
