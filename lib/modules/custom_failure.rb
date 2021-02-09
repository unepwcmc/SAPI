class CustomFailure < Devise::FailureApp
  def redirect_url
    # Ensure both /admin and /admin/ redirect to sign in page
    if request.original_url.match(admin_root_path)
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
