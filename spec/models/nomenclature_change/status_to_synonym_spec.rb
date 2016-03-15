# == Schema Information
#
# Table name: nomenclature_changes
#
#  id            :integer          not null, primary key
#  event_id      :integer
#  type          :string(255)      not null
#  status        :string(255)      not null
#  created_by_id :integer          not null
#  updated_by_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe NomenclatureChange::StatusToSynonym do
  describe :validate do
    context "when required primary output missing" do
      context "when primary_output" do
        let(:status_change){
          build(
            :nomenclature_change_status_to_synonym,
            :status => NomenclatureChange::StatusToSynonym::PRIMARY_OUTPUT
          )
        }
        specify { expect(status_change).to have(1).error_on(:primary_output) }
      end
      context "when submitting" do
        let(:status_change){
          build(
            :nomenclature_change_status_to_synonym,
            :status => NomenclatureChange::StatusToSynonym::SUBMITTED
          )
        }
        specify { expect(status_change).to have(1).error_on(:primary_output) }
      end
    end
  end
end
