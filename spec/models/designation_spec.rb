# == Schema Information
#
# Table name: designations
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  taxonomy_id :integer          default(1), not null
#
# Foreign Keys
#
#  designations_taxonomy_id_fk  (taxonomy_id => taxonomies.id)
#

require 'spec_helper'

describe Designation do
  describe :create do
    context 'when valid' do
      let(:designation) { build(:designation, name: 'GALACTIC REGULATIONS') }
      specify { expect(designation).to be_valid }
    end
    context 'when name missing' do
      let(:designation) { build(:designation, name: nil) }
      specify { expect(designation).to be_invalid }
      specify { expect(designation).to have(1).error_on(:name) }
    end
    context 'when name duplicated' do
      let!(:designation1) { create(:designation) }
      let(:designation2) { build(:designation, name: designation1.name) }
      specify { expect(designation2).to be_invalid }
      specify { expect(designation2).to have(1).error_on(:name) }
    end
  end
  describe :update do
    context 'when updating a non-protected name' do
      let(:designation) { create(:designation) }
      specify do
        expect(designation.update(
          { name: 'RULES OF INTERGALACTIC TRADE' }
        )).to be_truthy
      end
    end
    context 'when updating a protected name' do
      specify do
        expect(cites.update(
          { name: 'RULES OF INTERGALACTIC TRADE' }
        )).to be_falsey
      end
    end
    context 'when updating taxonomy with no dependent objects attached' do
      let(:designation) { create(:designation) }
      let(:taxonomy) { create(:taxonomy) }
      specify { expect(designation.update(taxonomy_id: taxonomy.id)).to be_truthy }
    end
    context 'when updating taxonomy with dependent objects attached' do
      let(:designation) { create(:designation) }
      let!(:change_type) { create(:change_type, designation: designation) }
      let(:taxonomy) { create(:taxonomy) }
      specify { expect(designation.update(taxonomy_id: taxonomy.id)).to be_falsey }
    end
  end
  describe :destroy do
    context 'when no dependent objects attached' do
      let(:designation) { create(:designation, name: 'GALACTIC REGULATIONS') }
      specify { expect(designation.destroy).to be_truthy }
    end
    context 'when dependent objects attached' do
      let(:designation) { create(:designation, name: 'GALACTIC REGULATIONS') }
      let!(:change_type) { create(:change_type, designation: designation) }
      specify { expect(designation.destroy).to be_falsey }
    end
    context 'when protected name' do
      specify { expect(cites.destroy).to be_falsey }
    end
  end
end
