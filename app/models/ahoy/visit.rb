# == Schema Information
#
# Table name: ahoy_visits
#
#  id               :uuid             not null, primary key
#  browser          :string(255)
#  city             :string(255)
#  country          :string(255)
#  device_type      :string(255)
#  ip               :string(255)
#  landing_page     :text
#  organization     :text
#  os               :string(255)
#  referrer         :text
#  referring_domain :string(255)
#  search_keyword   :string(255)
#  started_at       :datetime
#  user_agent       :text
#  utm_campaign     :string(255)
#  utm_content      :string(255)
#  utm_medium       :string(255)
#  utm_source       :string(255)
#  utm_term         :string(255)
#  user_id          :integer
#  visitor_id       :uuid
#
# Indexes
#
#  index_ahoy_visits_on_user_id                    (user_id)
#  index_ahoy_visits_on_visitor_id_and_started_at  (visitor_id,started_at)
#
# Foreign Keys
#
#  ahoy_visits_user_id_fk  (user_id => users.id)
#

module Ahoy
  class Visit < ApplicationRecord
    self.table_name = 'ahoy_visits'

    has_many :ahoy_events, class_name: 'Ahoy::Event'
    belongs_to :user, optional: true
    serialize :properties, coder: JSON

    # https://github.com/ankane/ahoy/issues/549
    # This project start using ahoy since version 1.0.1
    # The DB migration file come with version 1.0.1 create columns `id` and `visitor_id`.
    # (https://github.com/ankane/ahoy/blob/v1.0.1/lib/generators/ahoy/stores/templates/active_record_visits_migration.rb)
    # However it has changed since version 1.4.0, from `id` to `visit_token`, and from `visitor_id` to `visitor_token`.
    # (https://github.com/ankane/ahoy/blob/v1.4.0/lib/generators/ahoy/stores/templates/active_record_visits_migration.rb)
    alias_attribute :visit_token, :id
    alias_attribute :visitor_token, :visitor_id
  end
end
