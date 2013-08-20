# == Schema Information
#
# Table name: eu_decisions
#
#  id                  :integer          not null, primary key
#  is_current          :boolean          default(TRUE)
#  notes               :text
#  internal_notes      :text
#  taxon_concept_id    :integer
#  geo_entity_id       :integer
#  start_date          :datetime
#  start_event_id      :integer
#  end_date            :datetime
#  end_event_id        :integer
#  type                :string(255)
#  conditions_apply    :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  eu_decision_type_id :integer
#  term_id             :integer
#  source_id           :integer
#

require 'digest/sha1'
require 'csv'
class EuDecision < ActiveRecord::Base
  attr_accessible :end_date, :end_event_id, :geo_entity_id, :internal_notes,
    :is_current, :notes, :start_date, :start_event_id, :eu_decision_type_id,
    :taxon_concept_id, :type, :conditions_apply, :term_id, :source_id

  belongs_to :taxon_concept, :touch => true
  belongs_to :m_taxon_concept, :foreign_key => :taxon_concept_id
  belongs_to :geo_entity
  belongs_to :eu_decision_type
  belongs_to :source, :class_name => 'TradeCode'
  belongs_to :term, :class_name => 'TradeCode'
  belongs_to :start_event, :class_name => 'Event'
  has_many :eu_decision_confirmations

  validates :start_date, presence: true
  validates :taxon_concept, presence: true
  validates :eu_decision_type, presence: true

  def year
    start_date ? start_date.strftime('%Y') : ''
  end

  def start_date_formatted
    start_date ? start_date.strftime("%d/%m/%Y") : ""
  end

  def party
    geo_entity.try(:name_en)
  end

  def start_event_name
    start_event.try(:name)
  end

  def decision_type
    if eu_decision_type.tooltip.present?
      "#{eu_decision_type.name} (#{eu_decision_type.tooltip})"
    else
      eu_decision_type.name
    end
  end

  def source_name
    source.try(:name_en)
  end

  def term_name
    term.try(:name_en)
  end

  def self.csv_columns_headers
    ['Date', 'Party', 'SRG', 'Source',
      'Term', 'Notes', 'Document']
  end

  def self.csv_columns
    [:start_date_formatted, :party, :decision_type,
      :term_name, :source_name, :notes, :start_event_name]
  end

  def self.export filters
    return false unless export_query(filters).any?
    path = "public/downloads/#{self.to_s.tableize}/"
    latest = self.order("updated_at DESC").
      limit(1).first.updated_at.strftime("%d%m%Y")
    public_file_name = "#{self.to_s.downcase}s_#{latest}.csv"
    file_name = Digest::SHA1.hexdigest(
      filters.merge(:latest_date => latest).
      to_hash.
      symbolize_keys!.sort
      .to_s
    )+"_#{self.to_s.downcase}s.csv"
    if !File.file?(path+file_name)
      self.to_csv(path+file_name, filters)
    end
    [
      path + file_name,
      { :filename => public_file_name, :type => 'text/csv' }
    ]
  end

  def self.export_query filters
    self.includes([:m_taxon_concept, :source, :geo_entity,
        :start_event, :term, :eu_decision_type]).
      filter_is_current(filters["set"]).
      filter_geo_entities(filters).
      filter_years(filters).
      filter_taxon_concepts(filters).
      filter_decision_type(filters["decision_types"]).
      order([:start_date, :"eu_decisions.id"])
  end


  def self.to_csv file_path, filters
    taxonomy_columns = [
      :kingdom_name, :phylum_name,
      :class_name, :order_name,
      :family_name, :genus_name,
      :species_name, :subspecies_name,
      :full_name, :rank_name
    ]
    limit = 1000
    offset = 0
    CSV.open(file_path, 'wb') do |csv|
      csv << taxonomy_columns + ['Remarks'] + self.csv_columns_headers
      ids = []
      until (objs = export_query(filters).limit(limit).
             offset(offset)).empty? do
        objs.each do |q|
          row = []
          row += self.fill_taxon_columns(q, taxonomy_columns)
          self.csv_columns.each do |c|
            row << q.send(c)
          end
          csv << row
        end
        offset += limit
       end
      end
  end

  def self.fill_taxon_columns eu_decision, taxonomy_columns
    columns = []
    taxon = eu_decision.m_taxon_concept
    return [""]*(taxonomy_columns.size+1) unless taxon #return array with empty strings
    taxonomy_columns.each do |c|
      columns << taxon.send(c)
    end
    if taxon.name_status == 'A'
      columns << '' #no remarks
    else
      columns << "Issued for #{taxon.name_status == 'S' ? 'synonym' : 'hybrid' }
        #{eu_decision.taxon_concept.full_name}"
    end
    columns
  end

  def self.filter_is_current set
    if set == "current"
      return where(:is_current => true)
    end
    scoped
  end

  def self.filter_geo_entities filters
    if filters.has_key?("geo_entities_ids")
      geo_entities_ids = GeoEntity.nodes_and_descendants(
        filters["geo_entities_ids"]
      ).map(&:id)
      return where(:geo_entity_id => geo_entities_ids)
    end
    scoped
  end

  def self.filter_taxon_concepts filters
    if filters.has_key?("taxon_concepts_ids")
      conds_str = <<-SQL
        ARRAY[
          taxon_concepts_mview.id, taxon_concepts_mview.family_id, 
          taxon_concepts_mview.order_id, taxon_concepts_mview.class_id, 
          taxon_concepts_mview.phylum_id, taxon_concepts_mview.kingdom_id
        ] && ARRAY[?]
        OR taxon_concept_id IS NULL
      SQL
      return where(conds_str, filters["taxon_concepts_ids"].map(&:to_i))
    end
    scoped
  end

  def self.filter_years filters
    if filters.has_key?("years")
      return where('EXTRACT(YEAR FROM eu_decisions.start_date) IN (?)',
                   filters["years"])
    end
    scoped
  end

  def self.filter_decision_type decision_types
    filtering = scoped
    if "false" == decision_types["negativeOpinions"]
      filtering = filtering.where('eu_decision_types.decision_type <> ?',
                                  EuDecisionType::NEGATIVE_OPINION)
    end
    if "false" == decision_types["positiveOpinions"]
      filtering = filtering.where('eu_decision_types.decision_type <> ?',
                                  EuDecisionType::POSITIVE_OPINION)
    end
    if "false" == decision_types["noOpinions"]
      filtering = filtering.where('eu_decision_types.decision_type <> ?',
                                  EuDecisionType::NO_OPINION)
    end
    if "false" == decision_types["suspensions"]
      filtering = filtering.where('eu_decision_types.decision_type <> ?',
                                  EuDecisionType::SUSPENSION)
    end
    filtering
  end
end
