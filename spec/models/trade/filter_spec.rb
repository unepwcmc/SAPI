require 'spec_helper'
describe Trade::Filter do
  include_context 'Shipments'

  describe :results do
    context "when searching by taxon concepts ids" do
      before(:each){ Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings }
      context "at GENUS rank" do
        subject { Trade::Filter.new({:taxon_concepts_ids => [@genus1.id]}).results }
        specify { subject.should include(@shipment1) }
        specify { subject.should_not include(@shipment2) }
        specify { subject.length.should == 1 }
      end
      context "at FAMILY rank" do
        subject { Trade::Filter.new({:taxon_concepts_ids => [@family.id]}).results }
        specify { subject.should include(@shipment1) }
        specify { subject.should include(@shipment2) }
        specify { subject.length.should == 4 }
      end
      context "at mixed ranks" do
        subject {
          Trade::Filter.new({
            :taxon_concepts_ids => [@genus1.id, @taxon_concept2.id]
          }).results
        }
        specify { subject.should include(@shipment1) }
        specify { subject.should include(@shipment2) }
        specify { subject.length.should == 4 }
      end
    end
    context "when searching by appendices" do
      subject { Trade::Filter.new({:appendices => ['I']}).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 1 }
    end

    context "when searching for terms_ids" do
      subject { Trade::Filter.new({:terms_ids => [@term.id]}).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 2 }
    end


    context "when searching for units_ids" do
      subject { Trade::Filter.new({:units_ids => [@unit.id]}).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 2 }
    end


    context "when searching for purposes_ids" do
      subject { Trade::Filter.new({:purposes_ids => [@purpose.id]}).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 4 }
    end


    context "when searching for sources_ids" do
      subject { Trade::Filter.new({:sources_ids => [@source.id]}).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 4 }
    end


    context "when searching for importers_ids" do
      subject { Trade::Filter.new({:importers_ids => [@argentina.id]}).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 1 }
    end

    context "when searching for exporters_ids" do
      subject { Trade::Filter.new({:exporters_ids => [@argentina.id]}).results }
      specify { subject.should include(@shipment2) }
      specify { subject.length.should == 3 }
    end

    context "when searching for countries_of_origin_ids" do
      subject { Trade::Filter.new({:countries_of_origin_ids => [@argentina.id]}).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 1 }
    end

    context "when searching by year" do
      context "when time range specified" do
        subject { Trade::Filter.new({:time_range_start => 2013, :time_range_end => 2015}).results }
        specify { subject.should include(@shipment2) }
        specify { subject.length.should == 3 }
      end
      context "when time range specified incorrectly" do
        subject { Trade::Filter.new({:time_range_start => 2013, :time_range_end => 2012}).results }
        specify { subject.length.should == 0 }
      end
      context "when time range start specified" do
        subject { Trade::Filter.new({:time_range_start => 2012}).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 4 }
      end
      context "when time range end specified" do
        subject { Trade::Filter.new({:time_range_end => 2012}).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 1 }
      end
    end

    context "when searching by reporter_type" do
      context "when reporter type is not I or E" do
        subject { Trade::Filter.new({:internal => true, :reporter_type => 'K'}).results }
        specify { subject.length.should == 4 }
      end

      context "when reporter type is I" do
        subject { Trade::Filter.new({:internal => true, :reporter_type => 'I'}).results }
        specify { subject.should include(@shipment2) }
        specify { subject.length.should == 3 }
      end

      context "when reporter type is E" do
        subject { Trade::Filter.new({:internal => true, :reporter_type => 'E'}).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 1 }
      end
    end


    context "when searching by permit" do
      context "when permit number" do
        subject { Trade::Filter.new({:internal => true, :permits_ids => [@export_permit1.id]}).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 1 }
      end
      context "when blank" do
        subject { Trade::Filter.new({:internal => true, :permit_blank => true}).results }
        specify { subject.should include(@shipment2) }
        specify { subject.length.should == 3 }
      end
      context "when both permit number and blank" do
        subject { Trade::Filter.new({:internal => true, :permits_ids => [@export_permit1.id], :permit_blank => true}).results }
        specify { subject.length.should == 4 }
      end
    end

    context "when searching by quantity" do
      subject { Trade::Filter.new({:internal => true, :quantity => 20}).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 1 }
    end
  end

  describe :total_cnt do
    context "when none matches" do
      subject { Trade::Filter.new({:appendices => ['III']}) }
      specify { subject.total_cnt.should == 0 }
    end

    context "when one matches" do
      subject { Trade::Filter.new({:appendices => ['I']}) }
      specify { subject.total_cnt.should == 1 }
    end

    context "when two match" do
      subject { Trade::Filter.new({:purposes_ids => [@purpose.id]}) }
      specify { subject.total_cnt.should == 4 }
    end


  end
end
