# == Schema Information
#
# Table name: eu_decisions
#
#  id                   :integer          not null, primary key
#  is_current           :boolean          default(TRUE)
#  notes                :text
#  internal_notes       :text
#  taxon_concept_id     :integer
#  geo_entity_id        :integer          not null
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
      specify { subject.should_not be_empty }
    end
  end

  describe :save do
    context "Eu decision type and SRG history can't be blank at the same time" do
      let(:eu_decision) { build(:eu_decision, srg_history_id: nil, eu_decision_type_id: nil) }
      subject { eu_decision.save }

      specify { subject.should be_falsey }

      it 'should have an error message' do
        subject
        expect(eu_decision.errors[:base]).to_not be_empty
      end
    end

    context 'Eu decision creates correctly if only Eu decision type is populated' do
      let(:eu_decision) { build(:eu_decision) }

      specify { subject.should be_truthy }
    end

    context 'Eu decision creates correctly if only SRG history is populated' do
      let(:eu_decision) { build(:eu_decision, eu_decision_type: nil, srg_history: create(:srg_history)) }

      specify { subject.should be_truthy }
    end

    context 'Eu decision creates correctly if both Eu decision type and SRG history are populated' do
      let(:eu_decision) { build(:eu_decision, srg_history: create(:srg_history)) }

      specify { subject.should be_truthy }
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
      specify { subject.should be_empty }
    end
  end

end
