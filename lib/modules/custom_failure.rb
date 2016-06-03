class CustomFailure < Devise::FailureApp
  def redirect_url
    if request.original_url == request.base_url + "/admin"
      new_user_session_path
    else
      root_path
    end
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
