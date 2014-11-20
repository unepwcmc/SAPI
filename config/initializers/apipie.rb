Apipie.configure do |config|
  config.app_name = "CITES Checklist and Species+ API"
  config.api_base_url = "/api/v2"
  config.doc_base_url = "/api/documentation"
  config.default_version = "v2"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v2/*.rb"
  config.layout = 'pages'
  config.copyright = "&copy; #{Time.now.year} UNEP-WCMC"
end
