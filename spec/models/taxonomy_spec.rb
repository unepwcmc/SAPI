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
    context 'when valid' do
      let(:taxonomy) { build(:taxonomy, name: 'WILDLIFE') }
      specify { expect(taxonomy).to be_valid }
    end
    context 'when name missing' do
      let(:taxonomy) { build(:taxonomy, name: nil) }
      specify { expect(taxonomy).to be_invalid }
      specify { expect(taxonomy).to have(1).error_on(:name) }
    end
    context 'when name duplicated' do
      let!(:taxonomy1) { create(:taxonomy) }
      let(:taxonomy2) { build(:taxonomy, name: taxonomy1.name) }
      specify { expect(taxonomy2).to be_invalid }
      specify { expect(taxonomy2).to have(1).error_on(:name) }
    end
  end
  describe :update do
    context 'when updating a non-protected name' do
      let(:taxonomy) { create(:taxonomy) }
      specify { expect(taxonomy.update({ name: 'WORLD OF LOLCATS' })).to be_truthy }
    end
    context 'when updating a protected name' do
      specify { expect(cites_eu.update({ name: 'WORLD OF LOLCATS' })).to be_falsey }
    end
  end
  describe :destroy do
    context 'when no dependent objects attached' do
      let(:taxonomy) { create(:taxonomy, name: 'WILDLIFE') }
      specify { expect(taxonomy.destroy).to be_truthy }
    end
    context 'when dependent objects attached' do
      let(:taxonomy) { create(:taxonomy, name: 'WILDLIFE') }
      let!(:designation) { create(:designation, taxonomy: taxonomy) }
      specify { expect(taxonomy.destroy).to be_falsey }
    end
    context 'when protected name' do
      specify { expect(cites_eu.destroy).to be_falsey }
    end
  end
end
