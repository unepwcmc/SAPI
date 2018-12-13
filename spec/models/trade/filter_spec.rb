require 'spec_helper'
describe Trade::Filter do
  include_context 'Shipments'

  describe :results do
    context "when searching by taxon concepts ids" do
      before(:each) { Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings }
      context "in the public interface" do
        context "at GENUS rank" do
          subject { Trade::Filter.new({
            :taxon_concepts_ids => [@animal_genus.id],
            :internal => false,
            :taxon_with_descendants => true
          }).results }
          specify { subject.should include(@shipment1) }
          specify { subject.should_not include(@shipment2) }
          specify { subject.length.should == 2 }
        end
        context "at FAMILY rank" do
          subject { Trade::Filter.new({
            :taxon_concepts_ids => [@animal_family.id],
            :internal => false,
            :taxon_with_descendants => false
          }).results }
          specify { subject.length.should == 0 }
        end
      end
      context "in the admin interface" do
        context "at GENUS rank" do
          subject { Trade::Filter.new({
            :taxon_concepts_ids => [@animal_genus.id],
            :internal => true
          }).results }
          specify { subject.should include(@shipment1) }
          specify { subject.should_not include(@shipment2) }
          specify { subject.length.should == 2 }
        end
        context "at FAMILY rank" do
          subject { Trade::Filter.new({
            :taxon_concepts_ids => [@plant_family.id],
            :internal => true
          }).results }
          specify { subject.should include(@shipment2) }
          specify { subject.should_not include(@shipment1) }
          specify { subject.length.should == 4 }
        end
        context "at mixed ranks" do
          subject {
            Trade::Filter.new({
              :taxon_concepts_ids => [@animal_genus.id, @plant_species.id],
              :internal => true
            }).results
          }
          specify { subject.should include(@shipment1) }
          specify { subject.should include(@shipment2) }
          specify { subject.length.should == 6 }
        end
      end
      context "when status N shipments present" do
        before(:each) do
          @shipment_of_status_N = create(:shipment, :taxon_concept_id => @status_N_species.id)
        end
        subject {
          Trade::Filter.new({
            :taxon_concepts_ids => [@status_N_species.id]
          }).results
        }
        specify { subject.should include(@shipment_of_status_N) }
      end
      context "when subspecies shipments present" do
        before(:each) do
          @shipment_of_subspecies = create(:shipment, :taxon_concept_id => @subspecies.id)
        end
        subject {
          Trade::Filter.new({
            :taxon_concepts_ids => [@animal_species.id]
          }).results
        }
        specify { subject.should include(@shipment_of_subspecies) }
      end
      context "when synonym subspecies shipments present" do
        before(:each) do
          @shipment_of_synonym_subspecies = create(
            :shipment,
            :reported_taxon_concept_id => @synonym_subspecies.id,
            :taxon_concept_id => @plant_species.id
          )
        end
        context "when searching by taxonomic parent" do
          subject {
            Trade::Filter.new({
              :taxon_concepts_ids => [@animal_species.id]
            }).results
          }
          specify { subject.should_not include(@shipment_of_synonym_subspecies) }
        end
        context "when searching by accepted name" do
          subject {
            Trade::Filter.new({
              :taxon_concepts_ids => [@plant_species.id]
            }).results
          }
          specify { subject.should include(@shipment_of_synonym_subspecies) }
        end
      end
    end
    context "when searching by reported taxon concepts ids" do
      before(:each) { Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings }
      context "when trade names shipments present" do
        before(:each) do
          @shipment_of_trade_name = create(
            :shipment,
            :reported_taxon_concept_id => @trade_name.id,
            :taxon_concept_id => @plant_species.id
          )
        end
        subject {
          Trade::Filter.new({
            :reported_taxon_concepts_ids => [@trade_name.id]
          }).results
        }
        specify { subject.should include(@shipment_of_trade_name) }
      end
    end
    context "when searching by appendices" do
      subject { Trade::Filter.new({ :appendices => ['I'] }).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 1 }
    end

    context "when searching for terms_ids" do
      subject { Trade::Filter.new({ :terms_ids => [@term_cav.id] }).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 3 }
    end

    context "when searching for units_ids" do
      subject { Trade::Filter.new({ :units_ids => [@unit.id] }).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 3 }
    end

    context "when searching for purposes_ids" do
      subject { Trade::Filter.new({ :purposes_ids => [@purpose.id] }).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 7 }
    end

    context "when searching for sources_ids" do
      context "when code" do
        subject { Trade::Filter.new({ :sources_ids => [@source.id] }).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 2 }
      end
      context "when blank" do
        subject { Trade::Filter.new({ :source_blank => true }).results }
        specify { subject.should include(@shipment6) }
        specify { subject.length.should == 1 }
      end
      context "when both code and blank" do
        subject { Trade::Filter.new({ :sources_ids => [@source.id], :source_blank => true }).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 3 }
      end
      context "when wild" do
        subject { Trade::Filter.new({ :sources_ids => [@source_wild.id], :source_blank => true }).results }
        specify { subject.should include(@shipment3) }
        specify { subject.length.should == 5 }
      end
      context "when wild and internal" do
        subject { Trade::Filter.new({
          :sources_ids => [@source_wild.id], :source_blank => true, :internal => true
        }).results }
        specify { subject.should include(@shipment3) }
        specify { subject.length.should == 4 }
      end
    end

    context "when searching for importers_ids" do
      subject { Trade::Filter.new({ :importers_ids => [@argentina.id] }).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 2 }
    end

    context "when searching for exporters_ids" do
      subject { Trade::Filter.new({ :exporters_ids => [@argentina.id] }).results }
      specify { subject.should include(@shipment2) }
      specify { subject.length.should == 5 }
    end

    context "when searching for countries_of_origin_ids" do
      subject { Trade::Filter.new({ :countries_of_origin_ids => [@argentina.id] }).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 2 }
    end

    context "when searching by year" do
      context "when time range specified" do
        subject { Trade::Filter.new({ :time_range_start => 2013, :time_range_end => 2015 }).results }
        specify { subject.should include(@shipment2) }
        specify { subject.length.should == 6 }
      end
      context "when time range specified incorrectly" do
        subject { Trade::Filter.new({ :time_range_start => 2013, :time_range_end => 2012 }).results }
        specify { subject.length.should == 0 }
      end
      context "when time range start specified" do
        subject { Trade::Filter.new({ :time_range_start => 2012 }).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 7 }
      end
      context "when time range end specified" do
        subject { Trade::Filter.new({ :time_range_end => 2012 }).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 1 }
      end
    end

    context "when searching by reporter_type" do
      context "when reporter type is not I or E" do
        subject { Trade::Filter.new({ :internal => true, :reporter_type => 'K' }).results }
        specify { subject.length.should == 7 }
      end

      context "when reporter type is I" do
        subject { Trade::Filter.new({ :internal => true, :reporter_type => 'I' }).results }
        specify { subject.should include(@shipment2) }
        specify { subject.length.should == 5 }
      end

      context "when reporter type is E" do
        subject { Trade::Filter.new({ :internal => true, :reporter_type => 'E' }).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 2 }
      end
    end

    context "when searching by permit" do
      context "when permit number" do
        subject { Trade::Filter.new({ :internal => true, :permits_ids => [@export_permit1.id] }).results }
        specify { subject.should include(@shipment1) }
        specify { subject.length.should == 1 }
      end
      context "when blank" do
        subject { Trade::Filter.new({ :internal => true, :permit_blank => true }).results }
        specify { subject.should include(@shipment2) }
        specify { subject.length.should == 5 }
      end
      context "when both permit number and blank" do
        subject { Trade::Filter.new({ :internal => true, :permits_ids => [@export_permit1.id], :permit_blank => true }).results }
        specify { subject.length.should == 6 }
      end
    end

    context "when searching by quantity" do
      subject { Trade::Filter.new({ :internal => true, :quantity => 20 }).results }
      specify { subject.should include(@shipment1) }
      specify { subject.length.should == 1 }
    end
  end

  describe :total_cnt do
    context "when none matches" do
      subject { Trade::Filter.new({ :appendices => ['III'] }) }
      specify { subject.total_cnt.should == 0 }
    end

    context "when one matches" do
      subject { Trade::Filter.new({ :appendices => ['I'] }) }
      specify { subject.total_cnt.should == 1 }
    end

    context "when two match" do
      subject { Trade::Filter.new({ :purposes_ids => [@purpose.id] }) }
      specify { subject.total_cnt.should == 7 }
    end

  end
end
