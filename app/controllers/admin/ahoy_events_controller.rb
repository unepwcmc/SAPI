class Admin::AhoyEventsController < Admin::StandardAuthorizationController
 respond_to :json
 layout :determine_layout
end