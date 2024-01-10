# == Schema Information
#
# Table name: ranks
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  taxonomic_position :string(255)      default("0"), not null
#  fixed_order        :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  display_name_en    :text             not null
#  display_name_es    :text
#  display_name_fr    :text
#

require 'spec_helper'

describe Rank do
  describe :parent_rank_lower_bound do
    context "obligatory rank" do
      let(:rank) { create(:rank, name: Rank::KINGDOM) }
      specify { rank.parent_rank_lower_bound.should == '0' }
    end
    context "optional rank" do
      let(:rank) { create(:rank, name: Rank::SUBFAMILY) }
      specify { rank.parent_rank_lower_bound.should == '5' }
    end
  end
  describe :create do
    context "when taxonomic position malformed" do
      let(:rank) { build(:rank, name: Rank::PHYLUM, taxonomic_position: '1.a.b') }
      specify { rank.should have(1).error_on(:taxonomic_position) }
    end
  end
  describe :destroy do
    context "when no dependent objects attached" do
      let(:rank) {
        r = create(:rank, name: Rank::PHYLUM, taxonomic_position: '1.1')
        r.update_attribute(:name, 'SUPER PHYLUM')
        r
      }
      specify { rank.destroy.should be_truthy }
    end
    context "when dependent objects attached" do
      let(:rank) { create(:rank, name: Rank::PHYLUM, taxonomic_position: '1.1') }
      let!(:taxon_concept) { create(:taxon_concept, :rank => rank) }
      specify { rank.destroy.should be_falsey }
    end
    context "when protected name" do
      let(:rank) { create(:rank, name: Rank::PHYLUM, taxonomic_position: '1.1') }
      specify { rank.destroy.should be_falsey }
    end
  end
  describe :in_range do
    context "when no bounds specified" do
      subject { Rank.in_range(nil, nil) }
      specify { subject.should == Rank.dict }
    end
    context "when lower bound specified" do
      subject { Rank.in_range(Rank::CLASS, nil) }
      specify { subject.should == [Rank::KINGDOM, Rank::PHYLUM, Rank::CLASS] }
    end
    context "when lower and upper bound specified" do
      subject { Rank.in_range(Rank::GENUS, Rank::FAMILY) }
      specify { subject.should == [Rank::FAMILY, Rank::SUBFAMILY, Rank::GENUS] }
    end
  end
end
