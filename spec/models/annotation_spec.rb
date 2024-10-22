# == Schema Information
#
# Table name: annotations
#
#  id                  :integer          not null, primary key
#  display_in_footnote :boolean          default(FALSE), not null
#  display_in_index    :boolean          default(FALSE), not null
#  full_note_en        :text
#  full_note_es        :text
#  full_note_fr        :text
#  parent_symbol       :string(255)
#  short_note_en       :text
#  short_note_es       :text
#  short_note_fr       :text
#  symbol              :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  created_by_id       :integer
#  event_id            :integer
#  import_row_id       :integer
#  original_id         :integer
#  updated_by_id       :integer
#
# Foreign Keys
#
#  annotations_created_by_id_fk  (created_by_id => users.id)
#  annotations_event_id_fk       (event_id => events.id)
#  annotations_source_id_fk      (original_id => annotations.id)
#  annotations_updated_by_id_fk  (updated_by_id => users.id)
#

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
