# == Schema Information
#
# Table name: trade_restrictions
#
#  id               :integer          not null, primary key
#  is_current       :boolean
#  start_date       :datetime
#  end_date         :datetime
#  geo_entity_id    :integer
#  quota            :float
#  publication_date :datetime
#  notes            :text
#  suspension_basis :string(255)
#  type             :string(255)
#  unit_id          :integer
#  taxon_concept_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  public_display   :boolean          default(TRUE)
#  url              :text
#  import_row_id    :integer
#

class Quota < TradeRestriction

  validates :quota, :presence => true
  validates :quota, :numericality => { :only_integer => true, :greater_than => 0 }

  validates :unit, :presence => true


  def year
    start_date ? start_date.strftime('%Y') : ''
  end

  def party
    geo_entity_id ? geo_entity.name_en : ''
  end

  def unit_name
    unit_id ? unit.name_en : ''
  end

  def self.export filters
    return false if !Quota.any?
    path = "public/downloads/"
    file_name = "quotas_#{Quota.order("updated_at DESC").
      limit(1).first.created_at.strftime("%d%m%Y")}.csv"
    if !File.file?(path+file_name)
      Quota.to_csv(path+file_name)
    end
    [ path+file_name,
      { :filename => file_name, :type => 'csv' } ]
  end

  def self.to_csv file_path
    require 'csv'
    taxonomy_columns = [
      :kingdom_name, :phylum_name,
      :class_name, :order_name,
      :family_name, :genus_name,
      :species_name, :subspecies_name,
      :full_name, :rank_name
    ]
    quota_columns = [
      :id, :year, :party, :quota,
      :unit_name, :publication_date,
      :notes, :url, :public_display
    ]
    limit = 1000
    offset = 0
    CSV.open(file_path, 'wb') do |csv|
      csv << taxonomy_columns + quota_columns
      ids = []
      until (quotas = Quota.
             includes([:m_taxon_concept, :geo_entity, :unit]).
             order([:start_date, :id]).limit(limit).
             offset(offset)).empty? do
        quotas.each do |q|
          row = []
          taxon = q.m_taxon_concept
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
    end
  end
end
