require 'spec_helper'

describe Designation do
  describe :create do
    context "when valid" do
      let(:designation){ build(:designation, :name => 'GALACTIC REGULATIONS') }
      specify {designation.should be_valid}
    end
    context "when name missing" do
      let(:designation){ build(:designation, :name => nil) }
      specify { designation.should be_invalid}
      specify { designation.should have(1).error_on(:name) }
    end
    context "when name duplicated" do
      let!(:designation1){ create(:designation) }
      let(:designation2){ build(:designation, :name => designation1.name) }
      specify { designation2.should be_invalid }
      specify { designation2.should have(1).error_on(:name) }
    end
  end
  describe :update do
    context "when updating a non-protected name" do
      let(:designation){ create(:designation) }
      specify{ designation.update_attributes(
        {:name => 'RULES OF INTERGALACTIC TRADE'}
      ).should be_true }
    end
    context "when updating a protected name" do
      let(:designation){ Designation.find_or_create_by_name(Designation::CITES) }
      specify{ designation.update_attributes(
        {:name => 'RULES OF INTERGALACTIC TRADE'}
      ).should be_false }
    end
    context "when updating taxonomy with no dependent objects attached" do
      let(:designation){ create(:designation) }
      let(:taxonomy){ create(:taxonomy) }
      specify{ designation.update_attributes(:taxonomy_id => taxonomy.id).should be_true }
    end
    context "when updating taxonomy with dependent objects attached" do
      let(:designation){ create(:designation) }
      let!(:change_type){ create(:change_type, :designation => designation)}
      let(:taxonomy){ create(:taxonomy) }
      specify{ designation.update_attributes(:taxonomy_id => taxonomy.id).should be_false }
    end
  end
  describe :destroy do
    context "when no dependent objects attached" do
      let(:designation){ create(:designation, :name => 'GALACTIC REGULATIONS') }
      specify { designation.destroy.should be_true }
    end
    context "when dependent objects attached" do
      let(:designation){ create(:designation, :name => 'GALACTIC REGULATIONS') }
      let!(:change_type){ create(:change_type, :designation => designation)}
      specify { designation.destroy.should be_false }
    end
    context "when protected name" do
      let(:designation){ Designation.find_or_create_by_name(Designation::CITES) }
      specify { designation.destroy.should be_false }
    end
  end
end
