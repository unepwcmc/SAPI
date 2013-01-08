# == Schema Information
#
# Table name: taxon_names
#
#  id              :integer          not null, primary key
#  scientific_name :string(255)      not null
#  basionym_id     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TaxonName < ActiveRecord::Base
  attr_accessible :basionym_id, :scientific_name

  def self.lower_bound(scientific_name)
    scientific_name.sub(/^\s+/, '').sub(/\s+$/, '').sub(/\s+/,' ').capitalize
  end
  def self.upper_bound(scientific_name)
    lower = lower_bound(scientific_name)
    (lower.length >= 2 ? lower[0..lower.length - 2] : '') +
      lower[lower.length - 1].next
  end
end
