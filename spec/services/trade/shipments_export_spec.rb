require 'spec_helper'

describe Trade::ShipmentsExport do
  before(:each) do
    4.times { create(:shipment) }
  end

  describe :total_cnt do
    context 'when internal' do
      subject { Trade::ShipmentsExport.new(internal: true, per_page: 4) }
      specify { expect(subject.total_cnt).to eq(4) }
    end
    context 'when public' do
      subject { Trade::ShipmentsExport.new(internal: false, per_page: 3) }
      specify { expect(subject.total_cnt).to eq(4) }
    end
  end

  describe :query do
    context 'when internal' do
      subject { Trade::ShipmentsExport.new(internal: true, per_page: 4) }
      specify { expect(subject.query.ntuples).to eq(4) }
    end
    context 'when public' do
      subject { Trade::ShipmentsExport.new(internal: false, per_page: 3) }
      specify { expect(subject.query.ntuples).to eq(3) }
    end
  end
end
