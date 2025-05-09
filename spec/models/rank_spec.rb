# == Schema Information
#
# Table name: ranks
#
#  id                 :integer          not null, primary key
#  display_name_en    :text             not null
#  display_name_es    :text
#  display_name_fr    :text
#  fixed_order        :boolean          default(FALSE), not null
#  name               :string(255)      not null
#  taxonomic_position :string(255)      default("0"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_ranks_on_display_name_en  (display_name_en) UNIQUE
#  index_ranks_on_display_name_es  (display_name_es) UNIQUE WHERE (display_name_es IS NOT NULL)
#  index_ranks_on_display_name_fr  (display_name_fr) UNIQUE WHERE (display_name_fr IS NOT NULL)
#  index_ranks_on_name             (name) UNIQUE
#

require 'spec_helper'

describe Rank do
  describe :parent_rank_lower_bound do
    context 'obligatory rank' do
      let(:rank) { create(:rank, name: Rank::KINGDOM) }
      specify { expect(rank.parent_rank_lower_bound).to eq('0') }
    end
    context 'optional rank' do
      let(:rank) { create(:rank, name: Rank::SUBFAMILY) }
      specify { expect(rank.parent_rank_lower_bound).to eq('5') }
    end
  end
  describe :create do
    context 'when taxonomic position malformed' do
      let(:rank) { build(:rank, name: Rank::PHYLUM, taxonomic_position: '1.a.b') }
      specify { expect(rank).to have(1).error_on(:taxonomic_position) }
    end
  end
  describe :destroy do
    context 'when no dependent objects attached' do
      let(:rank) do
        r = create(:rank, name: Rank::PHYLUM, taxonomic_position: '1.1')
        r.update_attribute(:name, 'SUPER PHYLUM')
        r
      end
      specify { expect(rank.destroy).to be_truthy }
    end
    context 'when dependent objects attached' do
      let(:rank) { create(:rank, name: Rank::PHYLUM, taxonomic_position: '1.1') }
      let!(:taxon_concept) { create(:taxon_concept, rank: rank) }
      specify { expect(rank.destroy).to be_falsey }
    end
    context 'when protected name' do
      let(:rank) { create(:rank, name: Rank::PHYLUM, taxonomic_position: '1.1') }
      specify { expect(rank.destroy).to be_falsey }
    end
  end
  describe :in_range do
    context 'when no bounds specified' do
      subject { Rank.in_range(nil, nil) }
      specify { expect(subject).to eq(Rank.dict) }
    end
    context 'when lower bound specified' do
      subject { Rank.in_range(Rank::CLASS, nil) }
      specify { expect(subject).to eq([ Rank::KINGDOM, Rank::PHYLUM, Rank::CLASS ]) }
    end
    context 'when lower and upper bound specified' do
      subject { Rank.in_range(Rank::GENUS, Rank::FAMILY) }
      specify { expect(subject).to eq([ Rank::FAMILY, Rank::SUBFAMILY, Rank::GENUS ]) }
    end
  end
end
