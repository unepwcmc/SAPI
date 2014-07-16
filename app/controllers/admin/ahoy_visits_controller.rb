class Admin::AhoyVisitsController < Admin::StandardAuthorizationController
 respond_to :json
 layout :determine_layout
end