# == Schema Information
#
# Table name: taxon_commons
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer          not null
#  common_name_id   :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  created_by_id    :integer
#  updated_by_id    :integer
#

require 'spec_helper'

describe TaxonCommon do
  describe :update do
    let(:language) {
      create(:language)
    }
    let(:parent) {
      create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatus')
      )
    }
    let!(:tc) {
      create_cites_eu_species(
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolatus')
      )
    }
    let!(:another_tc) {
      create_cites_eu_species(
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolcatus')
      )
    }
    let(:tc_common) {
      build(
        :taxon_common,
        :taxon_concept_id => tc.id,
        :name => 'Lolcat',
        :language_id => language.id
      )
    }
    context "when common name changed" do
      let(:another_tc_common) {
        build(
          :taxon_common,
          :taxon_concept_id => another_tc.id,
          :name => 'Lolcat',
          :language_id => language.id
        )
      }
      specify {
        tc_common.save
        another_tc_common.save
        tc_common.name = "Black lolcat"
        tc_common.save
        another_tc.common_names.map(&:name).should include('Lolcat')
      }
    end
  end
end
