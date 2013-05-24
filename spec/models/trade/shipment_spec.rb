# == Schema Information
#
# Table name: trade_shipments
#
#  id                            :integer          not null, primary key
#  source_id                     :integer
#  unit_id                       :integer
#  purpose_id                    :integer
#  term_id                       :integer
#  quantity                      :decimal(, )
#  reported_appendix             :string(255)
#  appendix                      :string(255)
#  trade_annual_report_upload_id :integer
#  exporter_id                   :integer
#  importer_id                   :integer
#  country_of_origin_id          :integer
#  country_of_origin_permit_id   :integer
#  import_permit_id              :integer
#  reported_by_exporter          :boolean
#  taxon_concept_id              :integer
#  reported_species_name         :string(255)
#  year                          :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

require 'spec_helper'

describe Trade::Shipment do
  pending "add some examples to (or delete) #{__FILE__}"
end
