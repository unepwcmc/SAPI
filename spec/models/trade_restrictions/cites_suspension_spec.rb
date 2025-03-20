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

describe CitesSuspension, sidekiq: :inline do
  let(:tanzania) do
    create(
      :geo_entity,
      geo_entity_type: country_geo_entity_type,
      name: 'United Republic of Tanzania',
      iso_code2: 'TZ'
    )
  end
  let(:rwanda) do
    create(
      :geo_entity,
      geo_entity_type: country_geo_entity_type,
      name: 'Republic of Rwanda',
      iso_code2: 'RW'
    )
  end
  before do
    travel -10.minutes
    @genus = create_cites_eu_genus
    @taxon_concept = create_cites_eu_species(parent: @genus)
    @another_taxon_concept = create_cites_eu_species
    create(
      :distribution,
      taxon_concept_id: @taxon_concept.id,
      geo_entity_id: tanzania.id
    )
    create(
      :distribution,
      taxon_concept_id: @another_taxon_concept.id,
      geo_entity_id: rwanda.id
    )
    travel_back
  end

  context 'touching taxa' do
    describe :create do
      context 'when taxon specific suspension' do
        subject do
          build(
            :cites_suspension,
            taxon_concept: @taxon_concept,
            start_notification: create_cites_suspension_notification
          )
        end
        specify do
          expect { subject.save }.to change { @taxon_concept.reload.dependents_updated_at }
        end
      end
      context 'when global suspension' do
        subject do
          build(
            :cites_suspension,
            taxon_concept_id: nil,
            geo_entity_id: tanzania.id,
            start_notification: create_cites_suspension_notification
          )
        end
        specify do
          expect { subject.save }.to change { @taxon_concept.reload.dependents_updated_at }
        end
      end
      context 'when suspension at higher taxonomic level' do
        subject do
          create(
            :cites_suspension,
            taxon_concept: @genus,
            start_notification: create_cites_suspension_notification
          )
        end
        specify do
          expect { subject.save }.to change { @taxon_concept.reload.dependents_updated_at }
        end
      end
    end
    describe :update do
      context 'when taxon specific suspension' do
        subject do
          create(
            :cites_suspension,
            taxon_concept: @taxon_concept,
            start_notification: create_cites_suspension_notification
          )
        end
        specify do
          expect { subject.update_attribute(:taxon_concept_id, @another_taxon_concept.id) }.
            to change { @taxon_concept.reload.dependents_updated_at }
        end
      end
      context 'when global suspension' do
        subject do
          create(
            :cites_suspension,
            taxon_concept_id: nil,
            geo_entity_id: tanzania.id,
            start_notification: create_cites_suspension_notification
          )
        end
        specify do
          expect { subject.update_attribute(:geo_entity_id, rwanda.id) }.
            to change { @taxon_concept.reload.dependents_updated_at }
        end
        specify do
          expect { subject.update_attribute(:geo_entity_id, rwanda.id) }.
            to change { @another_taxon_concept.reload.dependents_updated_at }
        end
      end
      context 'when suspension at higher taxonomic level' do
        subject do
          create(
            :cites_suspension,
            taxon_concept: @genus,
            start_notification: create_cites_suspension_notification
          )
        end
        specify do
          expect { subject.update_attribute(:geo_entity_id, rwanda.id) }.
            to change { @taxon_concept.reload.dependents_updated_at }
        end
      end
    end
    describe :destroy do
      context 'when taxon specific suspension' do
        subject do
          create(
            :cites_suspension,
            taxon_concept: @taxon_concept,
            start_notification: create_cites_suspension_notification
          )
        end
        specify do
          expect { subject.destroy }.to change { @taxon_concept.reload.dependents_updated_at }
        end
      end
      context 'when global suspension' do
        subject do
          create(
            :cites_suspension,
            taxon_concept_id: nil,
            geo_entity_id: tanzania.id,
            start_notification: create_cites_suspension_notification
          )
        end
        specify do
          expect { subject.destroy }.
            to change { @taxon_concept.reload.dependents_updated_at }
        end
      end
      context 'when suspension at higher taxonomic level' do
        subject do
          create(
            :cites_suspension,
            taxon_concept: @genus,
            start_notification: create_cites_suspension_notification
          )
        end
        specify do
          expect { subject.destroy }.
            to change { @taxon_concept.reload.dependents_updated_at }
        end
      end
    end
  end

  context 'validations' do
    describe :create do
      context 'when start notification missing' do
        let(:cites_suspension) do
          build(
            :cites_suspension,
            start_notification: nil,
            taxon_concept: @taxon_concept
          )
        end

        specify { expect(cites_suspension).not_to be_valid }
        specify { expect(cites_suspension.error_on(:start_notification).size).to eq(1) }
      end

      context 'when start date greater than end date' do
        let(:cites_suspension) do
          build(
            :cites_suspension,
            start_notification: create_cites_suspension_notification(effective_at: 1.week.from_now),
            end_notification: create_cites_suspension_notification(effective_at: 1.week.ago),
            taxon_concept: @taxon_concept
          )
        end

        specify { expect(cites_suspension).not_to be_valid }
        specify { expect(cites_suspension.error_on(:start_date).size).to eq(1) }
      end

      context 'when valid' do
        let(:cites_suspension) do
          build(
            :cites_suspension,
            taxon_concept: @taxon_concept,
            start_notification: create_cites_suspension_notification
          )
        end

        specify { expect(cites_suspension).to be_valid }
      end
    end
  end

  describe :create do
    context 'downloads cache should be populated' do
      before(:each) do
        DownloadsCache.clear_cites_suspensions
        create(
          :cites_suspension,
          taxon_concept_id: nil,
          geo_entity_id: tanzania.id,
          start_notification: create_cites_suspension_notification
        )
        CitesSuspension.export('set' => 'current')
      end
      subject { Dir["#{DownloadsCache.cites_suspensions_path}/*"] }
      specify { expect(subject).not_to be_empty }
    end
  end

  describe :destroy do
    context 'downloads cache should be cleared' do
      before(:each) do
        DownloadsCache.clear_cites_suspensions

        s = create(
          :cites_suspension,
          taxon_concept_id: nil,
          geo_entity_id: tanzania.id,
          start_notification: create_cites_suspension_notification
        )

        CitesSuspension.export('set' => 'current')

        s.destroy
      end

      subject { Dir["#{DownloadsCache.cites_suspensions_path}/*"] }
      specify do
        # Currently fails because the clearing happens in an after_commit hook,
        # which does not run until the test is over.
        pending 'Cannot easily test after_commit hooks'

        expect(subject).to be_empty
      end
    end
  end
end
