require 'spec_helper'
describe Checklist::TaxonConceptsController do
  describe 'XHR GET JSON autocomplete' do
    include_context 'Arctocephalus'
    context 'when searching by accepted name' do
      it 'returns 1 result' do
        get :autocomplete, format: 'json', xhr: true,
          params: { scientific_name: 'Arctocephalus townsendi' }
        expect(response.body).to have_json_size(1)
      end
    end
    context 'when query blank' do
      it 'returns 0 results' do
        get :autocomplete, format: 'json', xhr: true
        expect(response.body).to have_json_size(0)
      end
    end
  end
end
