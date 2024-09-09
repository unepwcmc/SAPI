# == Schema Information
#
# Table name: events
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  designation_id       :integer
#  description          :text
#  url                  :text
#  is_current           :boolean          default(FALSE), not null
#  type                 :string(255)      default("Event"), not null
#  effective_at         :datetime
#  published_at         :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  legacy_id            :integer
#  end_date             :datetime
#  subtype              :string(255)
#  updated_by_id        :integer
#  created_by_id        :integer
#  extended_description :text
#  multilingual_url     :text
#  elib_legacy_id       :integer
#

require 'spec_helper'

describe CitesCop do
  describe :create do
    context 'when designation invalid' do
      let(:cites_cop) do
        build(
          :cites_cop,
          designation: eu
        )
      end
      specify { expect(cites_cop).not_to be_valid }
      specify { expect(cites_cop).to have(1).error_on(:designation_id) }
    end
    context 'when effective_at is blank' do
      let(:cites_cop) do
        build(
          :cites_cop,
          effective_at: nil
        )
      end
      specify { expect(cites_cop).not_to be_valid }
      specify { expect(cites_cop).to have(1).error_on(:effective_at) }
    end
  end

  describe :destroy do
    let(:cites_cop) { create_cites_cop }

    context 'when no dependent objects attached' do
      specify { expect(cites_cop.destroy).to be_truthy }
    end

    context 'when dependent objects attached' do
      ##
      # NB: deleting EU regulation events will cause all its listing changes to
      # be deleted, whereas CITES CoPs will refuse to be deleted until its
      # listing changes are deleted.
      context 'when listing changes exist' do
        let!(:listing_change) { create_cites_I_addition(event: cites_cop) }
        specify { expect(cites_cop.destroy).to be_falsey }
      end

      context 'when listing change and annotation' do
        let!(:annotation) { create(:annotation, event: cites_cop) }
        let!(:listing_change) do
          create_cites_I_addition(
            event: cites_cop,
            annotation: annotation
          )
        end

        specify { expect(cites_cop.destroy).to be_falsey }
      end

      context 'when listing change and hash annotation' do
        let!(:hash_annotation) { create(:annotation, event: cites_cop) }
        let!(:listing_change) do
          create_cites_I_addition(
            event: cites_cop,
            hash_annotation: hash_annotation
          )
        end

        specify { expect(cites_cop.destroy).to be_falsey }
      end
    end
  end
end
