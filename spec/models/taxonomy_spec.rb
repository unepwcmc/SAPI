# == Schema Information
#
# Table name: taxonomies
#
#  id         :integer          not null, primary key
#  name       :string(255)      default("DEAFAULT TAXONOMY"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Taxonomy do
  describe :create do
    context "when valid" do
      let(:taxonomy) { build(:taxonomy, :name => 'WILDLIFE') }
      specify { taxonomy.should be_valid }
    end
    context "when name missing" do
      let(:taxonomy) { build(:taxonomy, :name => nil) }
      specify { taxonomy.should be_invalid }
      specify { taxonomy.should have(1).error_on(:name) }
    end
    context "when name duplicated" do
      let!(:taxonomy1) { create(:taxonomy) }
      let(:taxonomy2) { build(:taxonomy, :name => taxonomy1.name) }
      specify { taxonomy2.should be_invalid }
      specify { taxonomy2.should have(1).error_on(:name) }
    end
  end
  describe :update do
    context "when updating a non-protected name" do
      let(:taxonomy) { create(:taxonomy) }
      specify { taxonomy.update_attributes({ :name => 'WORLD OF LOLCATS' }).should be_truthy }
    end
    context "when updating a protected name" do
      specify { cites_eu.update_attributes({ :name => 'WORLD OF LOLCATS' }).should be_falsey }
    end
  end
  describe :destroy do
    context "when no dependent objects attached" do
      let(:taxonomy) { create(:taxonomy, :name => 'WILDLIFE') }
      specify { taxonomy.destroy.should be_truthy }
    end
    context "when dependent objects attached" do
      let(:taxonomy) { create(:taxonomy, :name => 'WILDLIFE') }
      let!(:designation) { create(:designation, :taxonomy => taxonomy) }
      specify { taxonomy.destroy.should be_falsey }
    end
    context "when protected name" do
      specify { cites_eu.destroy.should be_falsey }
    end
  end
end
