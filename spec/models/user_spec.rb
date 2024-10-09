# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  authentication_token   :string(255)
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  is_active              :boolean          default(TRUE), not null
#  is_cites_authority     :boolean          default(FALSE), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  name                   :string(255)      not null
#  organisation           :text             default("UNKNOWN"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  role                   :text             default("api"), not null
#  sign_in_count          :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  geo_entity_id          :integer
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

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
