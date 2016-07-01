# == Schema Information
#
# Table name: documents
#
#  id                           :integer          not null, primary key
#  title                        :text             not null
#  filename                     :text             not null
#  date                         :date             not null
#  type                         :string(255)      not null
#  is_public                    :boolean          default(FALSE), not null
#  event_id                     :integer
#  language_id                  :integer
#  elib_legacy_id               :integer
#  created_by_id                :integer
#  updated_by_id                :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  sort_index                   :integer
#  primary_language_document_id :integer
#  elib_legacy_file_name        :text
#  original_id                  :integer
#  discussion_id                :integer
#  discussion_sort_index        :integer
#  designation_id               :integer
#

require 'spec_helper'

describe Document, sidekiq: :inline do

  describe :create do
    context "when date is blank" do
      let(:document) {
        build(
          :document,
          :date => nil
        )
      }
      specify { expect(document).to be_invalid }
      specify { expect(document).to have(1).error_on(:date) }
    end
    context "setting title from filename" do
      let(:document) { create(:document) }
      specify { expect(document.title).to eq('Annual report upload exporter') }
    end
    context "when specified designation conflicts with event" do
      let(:cites_cop) { create_cites_cop }
      let(:document) {
        create(:document, event: cites_cop, designation: eu)
      }
      specify { expect(document.designation).to eq(cites) }
    end
    context "when documents with same language and same primary document" do
      let(:language) { create(:language) }
      let(:primary_document) { create(:document) }
      let!(:document1) { create(:document,
                              language_id: language.id,
                              primary_language_document_id: primary_document.id)
      }

      let(:document2) { build(:document,
                            language_id: language.id,
                            primary_language_document_id: primary_document.id)
      }

      specify { expect(document2).to be_invalid }
      specify { expect(document2).to have(1).error_on(:primary_language_document_id) }

    end
  end

  describe :update do
    let(:primary_document) {
      create(:proposal, sort_index: 1)
    }
    let!(:secondary_document) {
      create(:proposal,
        sort_index: 2,
        primary_language_document_id: primary_document.id
      )
    }
    context "when primary document sort_index_updated" do
      specify "secondary document sort_index is in sync" do
        primary_document.update_attributes(sort_index: 3)
        expect(secondary_document.reload.sort_index).to eq(3)
      end
    end
    context "when secondary document sort_index_updated" do
      specify "primary document sort_index is in sync" do
        secondary_document.update_attributes(sort_index: 3)
        expect(primary_document.reload.sort_index).to eq(3)
      end
    end
  end

  describe :destroy do
    let(:primary_document) {
      create(:proposal)
    }
    let!(:secondary_document) {
      create(:proposal, primary_language_document_id: primary_document.id)
    }
    context "when secondary document destroyed" do
      specify "document count decreases by 1" do
        expect {
          secondary_document.destroy
        }.to change { Document.count }.by(-1)
      end
    end
    context "when primary document destroyed" do
      specify "document count decreases by 1" do
        expect {
          primary_document.destroy
        }.to change { Document.count }.by(-1)
      end
      specify "secondary document becomes primary" do
        primary_document.destroy
        expect(secondary_document.primary_language_document).to be_nil
      end
    end
  end
end
