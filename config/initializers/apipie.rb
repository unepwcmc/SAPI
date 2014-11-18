Apipie.configure do |config|
  config.app_name = "CITES Checklist and Species+ API"
  config.api_base_url = "/api/v2"
  config.doc_base_url = "/api/documentation"
  config.default_version = "v2"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v2/*.rb"

  config.app_info = <<-EOS
      == About the API
      Application Programming Interface (API) to support CITES Parties to increase the 
      accuracy and efficiency of curating CITES species data for permitting purposes.

      == Getting Started
      === Authenticating your requests
      You can sign up for an API account here ???. Once you have signed up, visit ???? 
      wj9402u9 an-jkgj and get your token. This token will need to be passed in to all
      requests as the value of a key named 'token' in the query string as below:

        http://www.speciesplus.net/api/v2/taxon_concepts/?token="abcd1234"

      === Pagination
      Where the request returns more than 100 objects, the request is paginated, showing 
      100 objects at a time. To fetch the remaining objects, you will need to make a new 
      request and pass the optional ‘page’ parameter like as below:

        http://www.speciesplus.net/api/v2/taxon_concepts/?token=abcd1234&page=2

      == Terms of Use
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in arcu suscipit, 
      egestas eros nec, scelerisque purus. Aenean venenatis lacus placerat euismod auctor. 
      Sed vitae dui metus. Ut id ex quis tortor suscipit semper vel non nisl. Aliquam erat 
      volutpat. Donec mattis consequat felis, lobortis pharetra justo faucibus sed.

      == Contact
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in arcu suscipit, 
      egestas eros nec, scelerisque purus. Aenean venenatis lacus placerat euismod auctor. 
      Sed vitae dui metus. Ut id ex quis tortor suscipit semper vel non nisl. Aliquam erat 
      volutpat. Donec mattis consequat felis, lobortis pharetra justo faucibus sed.
    EOS

  config.copyright = "&copy; #{Time.now.year} UNEP-WCMC"
end
