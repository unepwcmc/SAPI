if defined? NewRelic
  class ActionController::API
    include NewRelic::Agent::Instrumentation::ControllerInstrumentation
    if defined? NewRelic::Agent::Instrumentation::Rails3
      include NewRelic::Agent::Instrumentation::Rails3
    end
  end
end
