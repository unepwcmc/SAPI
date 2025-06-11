require 'spec_helper'
require 'cancan/matchers'

describe User do
  describe :create do
    context 'when organisation not given' do
      let(:user) { build(:user, organisation: nil) }
      specify { expect(user).to_not be_valid }
    end
  end
  describe :destroy do
    context 'when no dependent objects attached' do
      let(:user) { create(:user) }
      specify { expect(user.destroy).to be_truthy }
    end
    context 'when dependent objects attached' do
      let(:user) { create(:user) }
      before(:each) do
        RequestStore.store[:track_who_does_it_current_user] = user
        create(:shipment)
      end
      specify { expect(user.destroy).to be_falsey }
    end
  end

  describe 'abilities' do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }

    context 'when is a Data Manager' do
      let(:user) { create(:user, role: User::MANAGER) }

      it { is_expected.to be_able_to(:manage, :all) }
    end

    context 'when is a Data Contributor' do
      let(:user) { create(:user, role: User::CONTRIBUTOR) }

      it { is_expected.to be_able_to(:create, TaxonConcept) }
      it { is_expected.not_to be_able_to(:destroy, TaxonConcept) }
    end

    context 'when is a E-library Viewer' do
      let(:user) { create(:user, role: User::ELIBRARY_USER) }
      it { is_expected.not_to be_able_to(:manage, TaxonConcept) }
    end

    context 'when is an API User' do
      let(:user) { create(:user, role: User::API_USER) }
      it { is_expected.not_to be_able_to(:manage, TaxonConcept) }
    end

    context 'when is a Secretariat' do
      let(:user) { create(:user, role: User::SECRETARIAT) }
      it { is_expected.not_to be_able_to(:create, :all) }
      it { is_expected.not_to be_able_to(:update, :all) }
      it { is_expected.not_to be_able_to(:destroy, :all) }
    end

    context 'when is not active' do
      let(:user) { create(:user, role: User::MANAGER, is_active: false) }
      it { is_expected.not_to be_able_to(:create, :all) }
      it { is_expected.not_to be_able_to(:update, :all) }
      it { is_expected.not_to be_able_to(:destroy, :all) }
    end
  end
end
