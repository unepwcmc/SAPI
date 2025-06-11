require 'spec_helper'

describe Annotation do
  describe :validate do
    context 'symbol' do
      context 'should not be alphanumeric' do
        let(:annotation) do
          build(
            :annotation, parent_symbol: 'CoP1', symbol: '#1a'
          )
        end
        specify { expect(annotation).to have(1).errors_on(:symbol) }
      end
    end
  end

  describe :full_name do
    context 'when parent_symbol given' do
      let(:annotation) do
        create(:annotation, parent_symbol: 'CoP1', symbol: '#1')
      end
      specify { annotation.full_symbol == 'CoP1#1' }
    end
    context 'when event given' do
      let(:event) { create_cites_cop(name: 'CoP1') }
      let(:annotation) do
        create(:annotation, event_id: event.id, symbol: '#1')
      end
      specify { annotation.full_symbol == 'CoP1#1' }
    end
  end
  describe :destroy do
    let(:annotation) { create(:annotation) }
    context 'when no dependent objects attached' do
      specify { expect(annotation.destroy).to be_truthy }
    end
    context 'when dependent objects attached' do
      context 'when listing changes' do
        let!(:listing_change) { create_cites_I_addition(annotation_id: annotation.id) }
        specify { expect(annotation.destroy).to be_falsey }
      end
      context 'when hashed listing changes' do
        let!(:listing_change) { create_cites_I_addition(hash_annotation_id: annotation.id) }
        specify { expect(annotation.destroy).to be_falsey }
      end
    end
  end
end
