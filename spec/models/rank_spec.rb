require 'spec_helper'

describe Rank do
  describe :parent_rank_lower_bound do
    context "obligatory rank" do
      let(:rank) { create(:rank, :name => 'Kingdom', :taxonomic_position => '1') }
      specify {rank.parent_rank_lower_bound.should == '0'}
    end
    context "optional rank" do
      let(:rank) { create(:rank, :name => 'Infrakingdom', :taxonomic_position => '1.1.1') }
      specify {rank.parent_rank_lower_bound.should == '1.1'}
    end
  end
  describe :parent_rank_upper_bound do
    
  end
end