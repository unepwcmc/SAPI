class Country < ActiveRecord::Base
  has_many :distribution_components, :as => :component
  belongs_to :region
end
