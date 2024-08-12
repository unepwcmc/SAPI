# == Schema Information
#
# Table name: documents
#
#  id                           :integer          not null, primary key
#  date                         :date             not null
#  discussion_sort_index        :integer
#  elib_legacy_file_name        :text
#  filename                     :text             not null
#  general_subtype              :boolean
#  is_public                    :boolean          default(FALSE), not null
#  sort_index                   :integer
#  title                        :text             not null
#  type                         :string(255)      not null
#  volume                       :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  created_by_id                :integer
#  designation_id               :integer
#  discussion_id                :integer
#  elib_legacy_id               :integer
#  event_id                     :integer
#  language_id                  :integer
#  manual_id                    :text
#  original_id                  :integer
#  primary_language_document_id :integer
#  updated_by_id                :integer
#
# Indexes
#
#  index_documents_on_event_id                                      (event_id)
#  index_documents_on_language_id_and_primary_language_document_id  (language_id,primary_language_document_id) UNIQUE
#  index_documents_on_title_to_ts_vector                            (to_tsvector('simple'::regconfig, COALESCE(title, ''::text))) USING gin
#
# Foreign Keys
#
#  documents_created_by_id_fk                 (created_by_id => users.id)
#  documents_designation_id_fk                (designation_id => designations.id) ON DELETE => nullify
#  documents_event_id_fk                      (event_id => events.id)
#  documents_language_id_fk                   (language_id => languages.id)
#  documents_original_id_fk                   (original_id => documents.id) ON DELETE => nullify
#  documents_primary_language_document_id_fk  (primary_language_document_id => documents.id) ON DELETE => nullify
#  documents_updated_by_id_fk                 (updated_by_id => users.id)
#

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
      let!(:document1) do create(:document,
        language_id: language.id,
        primary_language_document_id: primary_document.id)
      end

      let(:document2) do build(:document,
        language_id: language.id,
        primary_language_document_id: primary_document.id)
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
      create(:proposal,
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
