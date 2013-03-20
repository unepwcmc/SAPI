# == Schema Information
#
# Table name: trade_restrictions
#
#  id               :integer          not null, primary key
#  is_current       :boolean
#  start_date       :datetime
#  end_date         :datetime
#  geo_entity_id    :integer
#  quota            :integer
#  publication_date :datetime
#  notes            :text
#  suspension_basis :string(255)
#  type             :string(255)
#  unit_id          :integer
#  taxon_concept_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Quota < TradeRestriction
  belongs_to :taxon_concept

  validates :quota, :presence => true
  validates :quota, :numericality => { :only_integer => true, :greater_than => 0 }

  validates :unit, :presence => true


  def self.to_csv
    require 'csv'
    taxonomy_columns = [
      :kingdom_name, :phylum_name,
      :class_name, :order_name,
      :family_name, :genus_name,
      :species_name, :subspecies_name,
      :full_name, :rank_name
    ]
    quota_columns = [
      :year, :party, :quota,
      :unit, :published_on
    ]
    limit = 1000
    offset = 0
    CSV.open("tmp/full_quotas_download.csv", 'wb') do |csv|
      csv << taxonomy_columns + quota_columns
      row = []
      self.where(:is_current => true).
        order(:start_date).
        limit(limit).offset(offset).each do |q|
          taxon = q.taxon_concept
          taxonomy_columns.each do |c|
            row << taxon.send(c)
          end
          quota_columns.each do |c|
            row << q.send(c)
          end
          csv << row
        end
      offset += limit
    end
    'tmp/full_quotas_download.csv'
  end
end
