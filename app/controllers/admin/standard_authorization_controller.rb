class Admin::StandardAuthorizationController < Admin::SimpleCrudController
  authorize_resource
end
