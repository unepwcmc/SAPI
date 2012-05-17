class Bru < ActiveRecord::Base
  has_many :distribution_components, :as => :component
  belongs_to :country
end
