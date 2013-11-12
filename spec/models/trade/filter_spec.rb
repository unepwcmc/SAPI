require 'spec_helper'
describe Trade::Filter do

  describe :results do
    before(:each) do
      @taxon_concept1 = create_cites_eu_species(
        :taxon_name => create(:taxon_name, :scientific_name => 'abstractus'),
        :parent => create_cites_eu_genus(:taxon_name => create(:taxon_name, :scientific_name => 'Foobarus'))
      )
      @taxon_concept2 = create_cites_eu_species(
        :taxon_name => create(:taxon_name, :scientific_name => 'totalus'),
        :parent => create_cites_eu_genus(:taxon_name => create(:taxon_name, :scientific_name => 'Nullificus'))
      )
      @term = create(:term, :code => 'CAV')
      @unit = create(:unit, :code => 'KIL')
      @purpose = create(:purpose, :code => 'T')
      @source = create(:source, :code => 'W')
      @import_permit = create(:permit, :number => 'AAA')
      @export_permit1 = create(:permit, :number => 'BBB')
      @export_permit2 = create(:permit, :number => 'CCC')
      @shipment1 = create(
        :shipment,
        :taxon_concept => @taxon_concept1,
        :appendix => 'I',
        :purpose => @purpose,
        :source => @source,
        :term => @term,
        :unit => @unit,
        :year => 2012,
        :import_permit => @import_permit,
        :export_permits=> [@export_permit1, @export_permit2]
      )
      @shipment2 = create(
        :shipment,
        :taxon_concept => @taxon_concept2,
        :appendix => 'II',
        :purpose => @purpose,
        :source => @source,
        :term => @term,
        :unit => @unit,
        :year => 2013
      )
    end
    context "when searching by taxon concepts ids" do
      subject { Trade::Filter.new({:taxon_concepts_ids => [@taxon_concept1.id]}).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 1 }
    end
    context "when searching by appendices" do
      subject { Trade::Filter.new({:appendices => ['I']}).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 1 }
    end
    context "when searching by year" do
      context "when time range specified" do
        subject { Trade::Filter.new({:time_range_start => 2013, :time_range_end => 2015}).results }
        specify { subject.should include(@shipment2) }
        specify { subject.length.should == 1 }
      end
      context "when time range specified incorrectly" do
        subject { Trade::Filter.new({:time_range_start => 2013, :time_range_end => 2012}).results }
        specify { subject.length.should == 0 }
      end
      context "when time range start specified" do
        subject { Trade::Filter.new({:time_range_start => 2012}).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 2 }
      end
      context "when time range end specified" do
        subject { Trade::Filter.new({:time_range_end => 2012}).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 1 }
      end
    end
    context "when searching by permit" do
      subject { Trade::Filter.new({:permits_ids => [@export_permit1.id]}).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 1 }
    end
  end
end