require 'exception_notifier'
class Ahoy::Store < Ahoy::Stores::ActiveRecordStore
  def report_exception(e)
    ExceptionNotifier.notify_exception(e)
  end
  def visit_model
    Ahoy::Visit
  end
end
Ahoy.quiet = false