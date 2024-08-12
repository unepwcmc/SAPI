require 'spec_helper'

describe DashboardStats do
  include_context 'Shipments'
  describe '#trade' do
    before(:each) do
      SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
      @shipment4_by_partner = create(
        :shipment,
        taxon_concept: @animal_species,
        appendix: 'II',
        purpose: @purpose,
        source: @source_wild,
        term: @term_liv,
        unit: nil,
        importer: @portugal,
        exporter: @argentina,
        country_of_origin: nil,
        year: 2013,
        reported_by_exporter: true,
        quantity: 40
      )
      @shipment_with_different_purpose = create(
        :shipment,
        taxon_concept: @animal_species,
        appendix: 'II',
        purpose: create(:purpose, code: 'Z'),
        source: @source_wild,
        term: @term_liv,
        unit: nil,
        importer: @portugal,
        exporter: @argentina,
        country_of_origin: nil,
        year: 2013,
        reported_by_exporter: false,
        quantity: 1
      )
    end
    context 'when no time range specified' do
      subject do
        DashboardStats.new(@argentina, {
          kingdom: 'Animalia', trade_limit: 5,
          time_range_start: 2010, time_range_end: 2013
        }).trade
      end
      it 'argentina should have 40 exported animals and no imports' do
        expect(subject[:exports][:top_traded].length).to eq(1)
        expect(subject[:exports][:top_traded][0][:count]).to eq 40
        expect(subject[:imports][:top_traded].length).to eq 0
      end
    end
    context 'when time range specified' do
      subject do
        DashboardStats.new(@argentina, {
          kingdom: 'Animalia',
          trade_limit: 5,
          time_range_start: 2012, time_range_end: 2012
        }).trade
      end
      it 'argentina should have no exports in 2012-2012' do
        expect(subject[:exports][:top_traded].length).to eq(0)
      end
    end
  end
end
