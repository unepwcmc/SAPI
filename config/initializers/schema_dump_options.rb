if ENV['SECRET_KEY_BASE_DUMMY'].blank?
  ActiveRecord::SchemaDumper.ignore_tables <<
    ActiveRecord::Base.connection.data_sources.grep(/^trade_sandbox_\d+/)
end
