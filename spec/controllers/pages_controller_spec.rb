require 'spec_helper'

describe PagesController do
  describe 'GET eu_legislation' do
    before(:each) do
      @ar1 = create_eu_regulation(effective_at: '2014-09-01')
      @ar2 = create_eu_regulation(effective_at: '2014-09-02')
    end
    it 'assigns annex regulations sorted by effective_at' do
      get :eu_legislation
      expect(assigns(:eu_annex_regulations)).to eq([ @ar2, @ar1 ])
    end
    it 'assigns suspension regulations' do
      get :eu_legislation
      expect(assigns(:eu_suspension_regulations)).not_to be_nil
    end
  end
end
