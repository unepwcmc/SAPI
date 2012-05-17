class Region < ActiveRecord::Base
  has_many :distribution_components, :as => :component
end
