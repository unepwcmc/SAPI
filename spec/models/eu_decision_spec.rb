# == Schema Information
#
# Table name: eu_decisions
#
#  id                   :integer          not null, primary key
#  conditions_apply     :boolean
#  end_date             :datetime
#  internal_notes       :text
#  is_current           :boolean          default(TRUE)
#  nomenclature_note_en :text
#  nomenclature_note_es :text
#  nomenclature_note_fr :text
#  notes                :text
#  start_date           :datetime
#  type                 :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  document_id          :integer
#  end_event_id         :integer
#  eu_decision_type_id  :integer
#  geo_entity_id        :integer          not null
#  source_id            :integer
#  srg_history_id       :integer
#  start_event_id       :integer
#  taxon_concept_id     :integer
#  term_id              :integer
#  updated_by_id        :integer
#
# Indexes
#
#  index_eu_decisions_on_document_id  (document_id)
#
# Foreign Keys
#
#  eu_decisions_created_by_id_fk        (created_by_id => users.id)
#  eu_decisions_end_event_id_fk         (end_event_id => events.id)
#  eu_decisions_eu_decision_type_id_fk  (eu_decision_type_id => eu_decision_types.id)
#  eu_decisions_geo_entity_id_fk        (geo_entity_id => geo_entities.id)
#  eu_decisions_source_id_fk            (source_id => trade_codes.id)
#  eu_decisions_srg_history_id_fk       (srg_history_id => srg_histories.id)
#  eu_decisions_start_event_id_fk       (start_event_id => events.id)
#  eu_decisions_taxon_concept_id_fk     (taxon_concept_id => taxon_concepts.id)
#  eu_decisions_term_id_fk              (term_id => trade_codes.id)
#  eu_decisions_updated_by_id_fk        (updated_by_id => users.id)
#

#  id                   :integer          not null, primary key
#  is_current           :boolean          default(TRUE)
#  notes                :text
#  internal_notes       :text
#  taxon_concept_id     :integer
#  geo_entity_id        :integer
#  start_date           :datetime
#  start_event_id       :integer
#  end_date             :datetime
#  end_event_id         :integer
#  type                 :string(255)
#  conditions_apply     :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  eu_decision_type_id  :integer
#  term_id              :integer
#  source_id            :integer
#  created_by_id        :integer
#  updated_by_id        :integer
#  nomenclature_note_en :text
#  nomenclature_note_es :text
#  nomenclature_note_fr :text
#

require 'spec_helper'

describe EuDecision, sidekiq: :inline do
  before do
    @taxon_concept = create(:taxon_concept)
  end

  describe :create do
    context "downloads cache should be populated" do
      before(:each) do
        DownloadsCache.clear_eu_decisions
        create(:eu_decision, :start_date => Time.utc(2013), :type => 'EuOpinion')
        Species::EuDecisionsExport.new(set: 'current', decision_types: {}).export
      end
      subject { Dir["#{DownloadsCache.eu_decisions_path}/*"] }
      specify { expect(subject).not_to be_empty }
    end
  end

  describe :save do
    context "Eu decision type and SRG history can't be blank at the same time" do
      let(:eu_decision) { build(:eu_decision, srg_history_id: nil, eu_decision_type_id: nil) }
      subject { eu_decision.save }

      specify { expect(subject).to be_falsey }

      it 'should have an error message' do
        subject
        expect(eu_decision.errors[:base]).to_not be_empty
      end
    end

    context 'Eu decision creates correctly if only Eu decision type is populated' do
      let(:eu_decision) { build(:eu_decision) }

      specify { expect(subject).to be_truthy }
    end

    context 'Eu decision creates correctly if only SRG history is populated' do
      let(:eu_decision) { build(:eu_decision, eu_decision_type: nil, srg_history: create(:srg_history)) }

      specify { expect(subject).to be_truthy }
    end

    context 'Eu decision creates correctly if both Eu decision type and SRG history are populated' do
      let(:eu_decision) { build(:eu_decision, srg_history: create(:srg_history)) }

      specify { expect(subject).to be_truthy }
    end
  end

  describe :destroy do
    context "downloads cache should be cleared" do
      before(:each) do
        DownloadsCache.clear_eu_decisions
        d = create(:eu_decision, :start_date => Time.utc(2013))
        Species::EuDecisionsExport.new(set: 'current', decision_types: {}).export
        d.destroy
        Species::EuDecisionsExport.new(set: 'current', decision_types: {}).export
      end
      subject { Dir["#{DownloadsCache.eu_decisions_path}/*"] }
      specify { expect(subject).to be_empty }
    end
  end

end
