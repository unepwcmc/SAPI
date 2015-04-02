class ApiRequest < ActiveRecord::Base
  serialize :params, JSON

  belongs_to :user

  def self.top_5_most_active_users
    self.where('created_at > ? AND user_id IS NOT NULL', 30.days.ago).group_by(&:user).sort_by { |k,v| -v.count }[0..4]
  end

  def self.last_30_days_requests
    self.group(:response_status).order(:response_status).group_by_day(:created_at, range: 30.days.ago.midnight..Time.now).count
  end
end