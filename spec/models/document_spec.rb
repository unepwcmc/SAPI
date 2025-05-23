require 'spec_helper'

describe Document, sidekiq: :inline do
  describe :create do
    context 'when date is blank' do
      let(:document) do
        build(
          :document,
          date: nil
        )
      end
      specify { expect(document).not_to be_valid }
      specify { expect(document).to have(1).error_on(:date) }
    end
    context 'setting title from filename' do
      let(:document) { create(:document) }
      specify { expect(document.title).to eq('Annual report upload exporter') }
    end
    context 'when specified designation conflicts with event' do
      let(:cites_cop) { create_cites_cop }
      let(:document) do
        create(:document, event: cites_cop, designation: eu)
      end
      specify { expect(document.designation).to eq(cites) }
    end
    context 'when documents with same language and same primary document' do
      let(:language) { create(:language) }
      let(:primary_document) { create(:document) }
      let!(:document1) do create(
        :document,
        language_id: language.id,
        primary_language_document_id: primary_document.id
      )
      end

      let(:document2) do build(
        :document,
        language_id: language.id,
        primary_language_document_id: primary_document.id
      )
      end

      specify { expect(document2).not_to be_valid }
      specify { expect(document2).to have(1).error_on(:primary_language_document_id) }
    end
  end

  describe :update do
    let(:primary_document) do
      create(:proposal, sort_index: 1)
    end
    let!(:secondary_document) do
      create(
        :proposal,
        sort_index: 2,
        primary_language_document_id: primary_document.id
      )
    end
    context 'when primary document sort_index_updated' do
      specify 'secondary document sort_index is in sync' do
        primary_document.update(sort_index: 3)
        expect(secondary_document.reload.sort_index).to eq(3)
      end
    end
    context 'when secondary document sort_index_updated' do
      specify 'primary document sort_index is in sync' do
        secondary_document.update(sort_index: 3)
        expect(primary_document.reload.sort_index).to eq(3)
      end
    end
  end

  describe :destroy do
    let(:primary_document) do
      create(:proposal)
    end
    let!(:secondary_document) do
      create(:proposal, primary_language_document_id: primary_document.id)
    end
    context 'when secondary document destroyed' do
      specify 'document count decreases by 1' do
        expect do
          secondary_document.destroy
        end.to change { Document.count }.by(-1)
      end
    end
    context 'when primary document destroyed' do
      specify 'document count decreases by 1' do
        expect do
          primary_document.destroy
        end.to change { Document.count }.by(-1)
      end
      specify 'secondary document becomes primary' do
        primary_document.destroy
        expect(secondary_document.primary_language_document).to be_nil
      end
    end
  end
end
