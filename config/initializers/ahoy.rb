require 'sapi/geo_i_p'

class Ahoy::Store < Ahoy::DatabaseStore
  def authenticate(data)
    # https://github.com/ankane/ahoy/tree/v5.0.2?tab=readme-ov-file#gdpr-compliance-1
    # disables automatic linking of visits and users (for GDPR compliance)
  end

  def track_visit(data)
    # Map the new column names (since 1.4.0), to old column name (< 1.4.0).
    data[:id] = ensure_uuid(data.delete(:visit_token))
    data[:visitor_id] = ensure_uuid(data.delete(:visitor_token))

    geo_ip_data = Sapi::GeoIP.instance.resolve(request.ip)
    data[:country] = geo_ip_data[:country]
    data[:city] = geo_ip_data[:city]
    data[:organization] = geo_ip_data[:organization]

    super(data)
  end

  def track_event(data)
    # Map the new column names (since 1.4.0), to old column name (< 1.4.0).
    data[:id] = ensure_uuid(data.delete(:event_id))
    super(data)
  end

  def ensure_uuid(id)
    UUIDTools::UUID.parse(id).to_s
  rescue
    UUIDTools::UUID.sha1_create(UUIDTools::UUID.parse(Ahoy::Tracker::UUID_NAMESPACE), id).to_s
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
Ahoy.cookies = :none

# https://github.com/ankane/ahoy/tree/v2.2.1#exceptions
Safely.report_exception_method = ->(e) { Appsignal.add_exception(exception) if defined? Appsignal }
