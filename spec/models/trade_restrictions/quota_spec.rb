# == Schema Information
#
# Table name: trade_restrictions
#
#  id                          :integer          not null, primary key
#  is_current                  :boolean          default(TRUE)
#  start_date                  :datetime
#  end_date                    :datetime
#  geo_entity_id               :integer
#  quota                       :float
#  publication_date            :datetime
#  notes                       :text
#  type                        :string(255)
#  unit_id                     :integer
#  taxon_concept_id            :integer
#  public_display              :boolean          default(TRUE)
#  url                         :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  start_notification_id       :integer
#  end_notification_id         :integer
#  excluded_taxon_concepts_ids :string
#  original_id                 :integer
#  updated_by_id               :integer
#  created_by_id               :integer
#  internal_notes              :text
#  nomenclature_note_en        :text
#  nomenclature_note_es        :text
#  nomenclature_note_fr        :text
#  applies_to_import           :boolean          default(FALSE), not null
#

require 'spec_helper'

describe Quota, sidekiq: :inline do
  before do
    @taxon_concept = create(:taxon_concept)
  end

  describe :create do
    context 'downloads cache should be populated' do
      before(:each) do
        DownloadsCache.clear_quotas
        create(:quota, start_date: Time.utc(2013), geo_entity: create(:geo_entity))
        Quota.export('set' => 'current')
      end
      subject { Dir["#{DownloadsCache.quotas_path}/*"] }
      specify { expect(subject).not_to be_empty }
    end
  end

  describe :destroy do
    context 'downloads cache should be cleared' do
      before(:each) do
        DownloadsCache.clear_quotas
        q = create(:quota, start_date: Time.utc(2013), geo_entity: create(:geo_entity))
        Quota.export('set' => 'current')
        q.destroy
        Quota.export('set' => 'current')
      end
      subject { Dir["#{DownloadsCache.quotas_path}/*"] }
      specify { expect(subject).to be_empty }
    end
  end

  context 'validations' do
    describe :create do
      before(:all) do
        @unit = create(:unit)
      end

      context 'when valid' do
        let(:quota) do
          build(
            :quota,
            unit: @unit,
            taxon_concept: @taxon_concept,
            geo_entity: create(:geo_entity)
          )
        end

        specify { expect(quota).to be_valid }
      end

      context 'when quota missing' do
        let(:quota1) do
          build(
            :quota,
            quota: nil,
            unit: @unit,
            taxon_concept: @taxon_concept
          )
        end

        specify { expect(quota1).not_to be_valid }
        specify { expect(quota1.error_on(:quota).size).to eq(2) }
      end

      context 'when publication date missing' do
        let(:quota) do
          build(
            :quota,
            publication_date: nil,
            unit: @unit,
            taxon_concept: @taxon_concept
          )
        end

        specify { expect(quota).not_to be_valid }
        specify { expect(quota.error_on(:publication_date).size).to eq(1) }
      end

      context 'when start date greater than end date' do
        let(:quota) do
          build(
            :quota,
            start_date: 1.week.from_now,
            end_date: 1.week.ago,
            unit: @unit,
            taxon_concept: @taxon_concept
          )
        end

        specify { expect(quota).not_to be_valid }
        specify { expect(quota.error_on(:start_date).size).to eq(1) }
      end

      pending "doesn't save a quota without a unit" do
        let(:quota) do
          build(
            :quota,
            unit: nil,
            taxon_concept: @taxon_concept
          )
        end

        specify { quota.should_not be_valid }
        specify { quota.should have(1).error_on(:unit) }
      end
    end
  end
end
