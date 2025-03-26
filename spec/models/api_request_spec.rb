# == Schema Information
#
# Table name: api_requests
#
#  id              :integer          not null, primary key
#  action          :string(255)
#  controller      :string(255)
#  error_message   :text
#  format          :string(255)
#  ip              :string(255)
#  params          :text
#  response_status :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#
# Indexes
#
#  idx_on_user_id_response_status_created_at_04ab285ff3  (user_id,response_status,created_at)
#  index_api_requests_on_created_at                      (created_at)
#

require 'spec_helper'

describe ApiRequest do
  let(:api_user) do
    create(:user, role: 'api')
  end

  before(:each) do
    create(
      :api_request,
      user_id: api_user.id,
      controller: 'taxon_concepts',
      action: 'index',
      params: { 'name' => 'Mammalia' },
      format: 'json',
      ip: '127.0.0.1',
      response_status: 200,
      created_at: Date.yesterday
    )
    create(
      :api_request,
      user_id: api_user.id,
      controller: 'taxon_concepts',
      action: 'index',
      params: { 'name' => 'Mammalia' },
      format: 'json',
      ip: '127.0.0.1',
      response_status: 500,
      created_at: Date.today
    )
  end

  describe :top_50_most_active_users do
    subject do
      ApiRequest.top_50_most_active_users
    end
    specify do
      expect(subject.first.user_id).to eq(api_user.id)
    end
  end

  describe :recent_requests do
    subject do
      ApiRequest.recent_requests
    end
    specify do
      expect(subject).to eq(
        {
          [ 200, Date.yesterday.strftime('%Y-%m-%d') ] => 1,
          [ 200, Date.today.strftime('%Y-%m-%d') ] => 0,
          [ 500, Date.yesterday.strftime('%Y-%m-%d') ] => 0,
          [ 500, Date.today.strftime('%Y-%m-%d') ] => 1
        }
      )
    end
  end

  describe :requests_by_response_status do
    subject do
      ApiRequest.requests_by_response_status
    end
    specify do
      expect(subject).to eq(
        {
          '200' => 1,
          '400' => 0,
          '401' => 0,
          '404' => 0,
          '422' => 0,
          '500' => 1
        }
      )
    end
  end

  describe :requests_by_controller do
    subject do
      ApiRequest.requests_by_controller
    end
    specify do
      expect(subject).to eq(
        {
          'taxon_concepts' => 2,
          'distributions' => 0,
          'cites_legislation' => 0,
          'eu_legislation' => 0,
          'references' => 0
        }
      )
    end
  end
end
