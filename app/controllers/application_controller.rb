class ApplicationController < ActionController::API
  #before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers
  
  # For all responses in this controller, return the CORS access control headers.
  
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end
  
  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.
  
  def cors_preflight_check
    if request.method == :options

    end
  end
end
