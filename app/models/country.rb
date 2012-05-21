# == Schema Information
#
# Table name: countries
#
#  id         :integer         not null, primary key
#  iso_name   :string(255)     not null
#  iso2_code  :string(255)
#  iso3_code  :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  region_id  :integer
#  legacy_id  :integer
#

class Country < ActiveRecord::Base
  has_many :distribution_components, :as => :component
  belongs_to :region

  def as_json(options={})
    super(:only =>[:id, :region_id, :iso_name, :iso2_code])
  end

end
