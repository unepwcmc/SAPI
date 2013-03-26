# == Schema Information
#
# Table name: taxon_commons
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer          not null
#  common_name_id   :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe TaxonCommon do
    let(:lng){
      create(:language)
    }
    let(:parent){
      create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatus')
      )
    }
    let!(:tc){
      create_cites_eu_species(
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolatus')
      )
    }
    let!(:another_tc){
      create_cites_eu_species(
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolcatus')
      )
    }
    let(:tc_common){
      build(
        :taxon_common,
        :taxon_concept_id => tc.id,
        :common_name_attributes => {
          :name => 'Lolcat',
          :language_id => lng.id
        }
      )
    }
    let(:another_tc_common){
      build(
        :taxon_common,
        :taxon_concept_id => another_tc.id,
        :common_name_attributes => {
          :name => 'Lolcat',
          :language_id => lng.id
        }
      )
    }
    specify{
      tc_common.save
      another_tc_common.save
      tc_common.common_name_attributes = {:name => 'Black lolcat', :language_id => lng.id}
      tc_common.save
      another_tc.common_names.map(&:name).should include('Lolcat')
    }
end
