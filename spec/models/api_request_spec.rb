# == Schema Information
#
# Table name: api_requests
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  controller      :string(255)
#  action          :string(255)
#  format          :string(255)
#  params          :text
#  ip              :string(255)
#  response_status :integer
#  error_message   :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe ApiRequest do
  let(:api_user) {
    create(:user, role: 'api')
  }

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
    subject {
      ApiRequest.top_50_most_active_users
    }
    specify {
      expect(subject.first.user_id).to eq(api_user.id)
    }
  end

  describe :recent_requests do
    subject {
      ApiRequest.recent_requests
    }
    specify {
      expect(subject).to eq({
        [200, Date.yesterday.strftime('%Y-%m-%d')] => 1,
        [200, Date.today.strftime('%Y-%m-%d')] => 0,
        [500, Date.yesterday.strftime('%Y-%m-%d')] => 0,
        [500, Date.today.strftime('%Y-%m-%d')] => 1
      })
    }
  end

  describe :requests_by_response_status do
    subject {
      ApiRequest.requests_by_response_status
    }
    specify {
      expect(subject).to eq({
        '200' => 1,
        '400' => 0,
        '401' => 0,
        '404' => 0,
        '422' => 0,
        '500' => 1
      })
    }
  end

  describe :requests_by_controller do
    subject {
      ApiRequest.requests_by_controller
    }
    specify {
      expect(subject).to eq({
        'taxon_concepts' => 2,
        'distributions' => 0,
        'cites_legislation' => 0,
        'eu_legislation' => 0,
        'references' => 0
      })
    }
  end
end
