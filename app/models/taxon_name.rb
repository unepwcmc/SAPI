# == Schema Information
#
# Table name: taxon_names
#
#  id              :integer          not null, primary key
#  scientific_name :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TaxonName < ActiveRecord::Base
  attr_accessible :basionym_id, :scientific_name

  validates :scientific_name, :presence => true

  def self.sanitize_scientific_name(some_scientific_name)
    last = some_scientific_name && some_scientific_name.split(/\s/).last
    last && last.capitalize || nil
  end

end
