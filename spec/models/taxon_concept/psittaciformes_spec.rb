require 'spec_helper'

describe TaxonConcept do
  context "Psittaciformes" do
    include_context "Psittaciformes"

    context "LISTING" do
      describe :current_listing do
        it "should correctly interpret up / down listing" do
          pending "fix history processing"
        end
        it "should be I/II/NC at order level Psittaciformes" do
          @order.current_listing.should == 'I/II/NC'
        end
        it "should be I at species level Cacatua goffiniana" do
          @species1_2_1.current_listing.should == 'I'
        end
        it "should be II at species level Cacatua ducorpsi (H)" do
          @species1_2_2.current_listing.should == 'II'
        end
        it "should be I at species level Probosciger aterrimus" do
          @species1_1.current_listing.should == 'I'
        end
        it "should be II at species level Amazona aestiva" do
          @species2_2.current_listing.should == 'II'
        end
        it "should be NC at species level Agapornis roseicollis" do
          @species2_1.current_listing.should == 'NC'
        end
      end
    end
  end
end