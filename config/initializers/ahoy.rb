class Ahoy::Store < Ahoy::Stores::ActiveRecordStore
  def report_exception(e)
    ExceptionNotifier.notify_exception(e) if defined? ExceptionNotifier
  end

  def visit_model
    Ahoy::Visit
  end

  def track_visit(options)
    visit = visit_model.new(
      {
        id: ahoy.visit_id,
        visitor_id: ahoy.visitor_id,
        user: user,
        started_at: options[:started_at]
      },
      :without_protection => true
    )
    visit_properties.keys.each do |key|
      visit.send(:"#{key}=", visit_properties[key]) if visit.respond_to?(:"#{key}=")
    end

    begin
      visit.save!
    rescue ActiveRecord::RecordNotUnique
      # do nothing
    end
  end

  def track_event(name, properties, options)
    event = event_model.new(
      {
        id: options[:id],
        visit_id: ahoy.visit_id,
        user: user,
        name: name,
        properties: properties,
        time: options[:time]
      },
      :without_protection => true
    )

    begin
      event.save!
    rescue ActiveRecord::RecordNotUnique
      # do nothing
    end
  end
end
Ahoy.quiet = false
