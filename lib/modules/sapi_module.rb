require 'sapi_module/stored_procedures.rb'
require 'sapi_module/indexes.rb'
require 'sapi_module/summary.rb'
module SapiModule
  def self.rebuild
    SapiModule::StoredProcedures.rebuild
  end

  def self.drop_indexes
    SapiModule::Indexes.drop_indexes
  end

  def self.create_indexes
    SapiModule::Indexes.create_indexes
  end

  def self.database_summary
    SapiModule::Summary.database_summary
  end
end
