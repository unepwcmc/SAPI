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

describe CitesSuspensionNotification do
  describe :create do
    context 'when designation invalid' do
      let(:cites_suspension_notification) do
        build(
          :cites_suspension_notification,
          designation: eu
        )
      end
      specify { expect(cites_suspension_notification).not_to be_valid }
      specify { expect(cites_suspension_notification).to have(1).error_on(:designation_id) }
    end
    context 'when effective_at is blank' do
      let(:cites_suspension_notification) do
        build(
          :cites_suspension_notification,
          effective_at: nil
        )
      end
      specify { expect(cites_suspension_notification).not_to be_valid }
      specify { expect(cites_suspension_notification).to have(1).error_on(:effective_at) }
    end
  end

  describe :destroy do
    let(:cites_suspension_notification) { create_cites_suspension_notification }
    context 'when no dependent objects attached' do
      specify { expect(cites_suspension_notification.destroy).to be_truthy }
    end
    context 'when dependent objects attached' do
      context 'when start notification' do
        let!(:cites_suspension) do
          create(
            :cites_suspension, start_notification: cites_suspension_notification
          )
        end
        specify { expect(cites_suspension_notification.destroy).to be_falsey }
      end
      context 'when end notification' do
        let!(:cites_suspension) do
          create(
            :cites_suspension,
            start_notification: create_cites_suspension_notification,
            end_notification: cites_suspension_notification
          )
        end
        specify { expect(cites_suspension_notification.destroy).to be_falsey }
      end
      context 'when confirmation notification, make sure it gets destroyed' do
        let!(:cites_suspension) do
          # Ideally we would create this in a single statement but on upgrading
          # from rails 4.0 to 4.1 this started failing - the joining table
          # was not being passed the correct id in the factory.
          # This seems to be the only test which fails for this reason.
          suspension = create(
            :cites_suspension,
            start_notification: create_cites_suspension_notification,
          )

          create(
            :cites_suspension_confirmation,
            confirmation_notification: cites_suspension_notification,
            confirmed_suspension: suspension,
          )

          suspension
        end
        subject { cites_suspension_notification.cites_suspension_confirmations }
        specify do
          cites_suspension_notification.destroy
          expect(subject.reload).to be_empty
        end
      end
    end
  end

  describe :end_date_formatted do
    let(:cites_suspension_notification) { create_cites_suspension_notification(end_date: '2012-05-10') }
    specify { expect(cites_suspension_notification.end_date_formatted).to eq('10/05/2012') }
  end

  describe :bases_for_suspension do
    let!(:cites_suspension_notification1) { create_cites_suspension_notification(subtype: 'A') }
    let!(:cites_suspension_notification2) { create_cites_suspension_notification(subtype: 'A') }
    let!(:cites_suspension_notification3) { create_cites_suspension_notification(subtype: 'B') }
    subject { CitesSuspensionNotification.bases_for_suspension }
    specify { subject.length == 2 }
  end
end
