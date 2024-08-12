# == Schema Information
#
# Table name: api_requests
#
#  id              :integer          not null, primary key
#  action          :string(255)
#  controller      :string(255)
#  error_message   :text
#  format          :string(255)
#  ip              :string(255)
#  params          :text
#  response_status :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#
# Indexes
#
#  index_api_requests_on_created_at  (created_at)
#

class ApiRequest < ApplicationRecord
  serialize :params, coder: JSON

  belongs_to :user, optional: true

  RECENT_DAYS = 90
  RECENT_MONTHS = 6

  scope :recent, -> { where('created_at > ?', RECENT_MONTHS.months.ago) }
  scope :by_response_status, -> { group(:response_status) }
  scope :by_controller, -> { group(:controller) }

  RESPONSE_STATUSES = [200, 400, 401, 404, 422, 500]
  CONTROLLERS = ['taxon_concepts', 'distributions', 'cites_legislation', 'eu_legislation', 'references']

  def self.top_50_most_active_users
    subquery = self.recent.select(
      [
        :user_id,
        'COUNT(*) AS cnt',
        'COUNT(NULLIF(response_status = 200, FALSE)) AS success_cnt',
        'COUNT(NULLIF(response_status = 200, TRUE)) AS failure_cnt'
      ]
    ).group(:user_id).
      where('user_id IS NOT NULL')
    self.from("(#{subquery.to_sql}) AS api_requests").
      order('cnt DESC').limit(50)
  end

  def self.recent_requests(user = nil)
    query = self.select([:response_status, :created_at]).recent.order(:response_status)
    query = query.where(user_id: user.id) if user
    query.group(:response_status).group_by_day(:created_at, format: '%Y-%m-%d').count(:all)
  end

  def self.requests_by_response_status(user = nil)
    subquery = select('response_status, COUNT(*) AS cnt')
    subquery = subquery.where(user_id: user.id) if user
    subquery = subquery.by_response_status
    hash_aggregate_by_keys('response_status', RESPONSE_STATUSES, subquery)
  end

  def self.requests_by_controller(user = nil)
    subquery = select('controller, COUNT(*) AS cnt')
    subquery = subquery.where(user_id: user.id) if user
    subquery = subquery.by_controller
    hash_aggregate_by_keys('controller', CONTROLLERS, subquery)
  end

  private

  def self.hash_aggregate_by_keys(key_name, key_ary, subquery)
    sql = ApplicationRecord.send(:sanitize_sql_array, [
      "SELECT JSON_OBJECT_AGG(#{key_name}_1, COALESCE(cnt, 0))
      FROM UNNEST(ARRAY[:key_ary]) #{key_name}_1
      LEFT JOIN (
        #{subquery.to_sql}
      ) s ON #{key_name}_1 = s.#{key_name}",
      key_ary: key_ary,
      key_name: key_name
    ])
    res = ApiRequest.find_by_sql(sql).first
    res['json_object_agg']
  end

end
