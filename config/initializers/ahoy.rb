require 'sapi/geoip'

class Ahoy::Store < Ahoy::DatabaseStore
  UUID_NAMESPACE = UUIDTools::UUID.parse("dcd74c26-8fc9-453a-a9c2-afc445c3258d")

  def authenticate(data)
    # disables automatic linking of visits and users
  end

  def visit_model
    Ahoy::Visit
  end

  def event_model
    Ahoy::Event
  end

  def visit
    @visit ||= visit_model.find_by(id: ensure_uuid(ahoy.visit_token)) if ahoy.visit_token
  end

  def track_visit(data)
    data[:id] = ensure_uuid(data.delete(:visit_token))
    data[:visitor_id] = ensure_uuid(data.delete(:visitor_token))

    geo_ip_data = Sapi::GeoIP.instance.resolve(request.ip)
    data[:country] = geo_ip_data[:country]
    data[:city] = geo_ip_data[:city]
    data[:organization] = geo_ip_data[:organization]

    super(data)
  end

  def track_event(data)
    data[:id] = ensure_uuid(data.delete(:event_id))
    super(data)
  end

  def ensure_uuid(id)
    UUIDTools::UUID.parse(id).to_s
  rescue
    UUIDTools::UUID.sha1_create(UUID_NAMESPACE, id).to_s
  end
end

Ahoy.quiet = false
Ahoy.api = true
Ahoy.server_side_visits = :when_needed
Ahoy.user_agent_parser = :device_detector
Ahoy.bot_detection_version = 2
Ahoy.track_bots = Rails.env.test?
Ahoy.geocode = false # we use our own geocoder (Sapi::GeoIP)
Ahoy.mask_ips = true
Ahoy.cookies = false # TODO: when upgrade to Ahoy v5, change value to :none

# https://github.com/ankane/ahoy/tree/v2.2.1#exceptions
Safely.report_exception_method = ->(e) { Appsignal.add_exception(exception) if defined? Appsignal }
