class ApiRequest < ActiveRecord::Base
  serialize :params, JSON

  belongs_to :user
end