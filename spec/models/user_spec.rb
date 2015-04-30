# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  role                   :text             default("api"), not null
#  authentication_token   :string(255)
#  organisation           :text             default("UNKNOWN"), not null
#  geo_entity_id          :integer
#  is_cites_authority     :boolean          default(FALSE), not null
#

require 'spec_helper'

describe User do
  describe :create do
    context "when organisation not given" do
      let(:user){ build(:user, organisation: nil) }
      specify{ expect(user).to_not be_valid}
    end
  end
  describe :destroy do
    context "when no dependent objects attached" do
      let(:user){ create(:user) }
      specify { user.destroy.should be_true }
    end
    context "when dependent objects attached" do
      let(:user){ create(:user) }
      before(:each){ user.make_current; create(:shipment) }
      specify { user.destroy.should be_false }
    end
  end
end
