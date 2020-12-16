class CustomFailure < Devise::FailureApp
  def redirect_url
    # Ensure both /admin and /admin/ redirect to sign in page
    regexp = Regexp.new("#{admin_root_path}(\/)?")

    if request.original_url.match(regexp)
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
