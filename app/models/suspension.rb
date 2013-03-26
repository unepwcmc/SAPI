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
#

class Suspension < TradeRestriction
  belongs_to :taxon_concept

  def self.export
    return false if !Suspension.any?
    path = "public/downloads/"
    file_name = "cites_suspensions_#{Suspension.order("updated_at DESC").
      limit(1).first.created_at.strftime("%d%m%Y")}.csv"
    if !File.file?(path+file_name)
      Suspension.to_csv(path+file_name)
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
    susp_columns = [
      :id, :start_date, :party, :quota,
      :unit_name, :publication_date,
      :notes, :url, :public_display
    ]
    limit = 1000
    offset = 0
    CSV.open(file_path, 'wb') do |csv|
      csv << taxonomy_columns + susp_columns
      ids = []
      until (quotas = Suspension.
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
