# == Schema Information
#
# Table name: taxon_names
#
#  id              :integer         not null, primary key
#  scientific_name :string(255)     not null
#  basionym_id     :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  abbreviation    :string(64)
#

class TaxonName < ActiveRecord::Base
  attr_accessible :basionym_id, :scientific_name, :abbreviation
end
