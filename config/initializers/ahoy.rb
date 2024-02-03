require 'sapi/geo_i_p'

class Ahoy::Store < Ahoy::DatabaseStore
  UUID_NAMESPACE = UUIDTools::UUID.parse("dcd74c26-8fc9-453a-a9c2-afc445c3258d")

  def authenticate(data)
    # https://github.com/ankane/ahoy/tree/v5.0.2?tab=readme-ov-file#gdpr-compliance-1
    # disables automatic linking of visits and users (for GDPR compliance)
  end

  def visit_model
    Ahoy::Visit
  end

  def event_model
    Ahoy::Event
  end

  # https://github.com/ankane/ahoy/issues/549
  # This project start using ahoy since version 1.0.1
  # The DB migration file come with version 1.0.1 create columns `id` and `visitor_id`.
  # (https://github.com/ankane/ahoy/blob/v1.0.1/lib/generators/ahoy/stores/templates/active_record_visits_migration.rb)
  # However it has changed since version 1.4.0, from `id` to `visit_token`, and from `visitor_id` to `visitor_token`.
  # (https://github.com/ankane/ahoy/blob/v1.4.0/lib/generators/ahoy/stores/templates/active_record_visits_migration.rb)
  # When we upgrade this gem, we need to check the source code of Ahoy::DatabaseStore,
  # (5.0.2 as reference: https://github.com/ankane/ahoy/blob/v5.0.2/lib/ahoy/database_store.rb)
  # see how the latest `visit` method look like, and override it with the old column names.
  def visit
    unless defined?(@visit)
      if ahoy.send(:existing_visit_token) || ahoy.instance_variable_get(:@visit_token)
        # find_by raises error by default with Mongoid when not found
        @visit = visit_model.where(id: ensure_uuid(ahoy.visit_token)).take if ahoy.visit_token
      elsif !Ahoy.cookies? && ahoy.visitor_token
        @visit = visit_model.where(visitor_id: ensure_uuid(ahoy.visitor_token)).where(started_at: Ahoy.visit_duration.ago..).order(started_at: :desc).first
      else
        @visit = nil
      end
    end
    @visit
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
Ahoy.cookies = :none

# https://github.com/ankane/ahoy/tree/v2.2.1#exceptions
Safely.report_exception_method = ->(e) { Appsignal.add_exception(exception) if defined? Appsignal }
