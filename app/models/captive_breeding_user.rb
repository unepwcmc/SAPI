# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean
#  authentication_token   :text
#  current_sign_in_at     :text
#  current_sign_in_ip     :text
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  is_active              :text
#  is_cites_authority     :text
#  last_sign_in_at        :text
#  last_sign_in_ip        :text
#  name                   :string
#  organisation           :text
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :text
#  sign_in_count          :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_id             :bigint
#  geo_entity_id          :text
#
# Indexes
#
#  index_users_on_country_id            (country_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class CaptiveBreedingUser < CaptiveBreedingRecord
  self.table_name = 'users'
end
