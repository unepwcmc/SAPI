#Encoding: UTF-8
require 'spec_helper'

describe Checklist do
  include_context "Psittaciformes"

  context "when filtering by appendix" do
    context "I" do
      before(:all) do
        @checklist = Checklist.new({
          :cites_appendices => ['I']
        })
        @taxon_concepts = @checklist.taxon_concepts_rel
      end
      it "should return Cacatua goffiniana" do
        @taxon_concepts.select{ |e| e.full_name == @species1_2_1.full_name }.first.should_not be_nil
      end

      it "should not return Agapornis roseicollis" do
        @taxon_concepts.select{ |e| e.full_name == @species2_1.full_name }.first.should be_nil
      end
    end

    context "Del" do
      before(:all) do
        @checklist = Checklist.new({
          :cites_appendices => ['del']
        })
        @taxon_concepts = @checklist.taxon_concepts_rel
      end
      it "should not return Cacatua goffiniana" do
        @taxon_concepts.select{ |e| e.full_name == @species1_2_1.full_name }.first.should be_nil
      end

      it "should return Agapornis roseicollis" do
        @taxon_concepts.select{ |e| e.full_name == @species2_1.full_name }.first.should_not be_nil
      end
    end

    context "NC" do
      before(:all) do
        @checklist = Checklist.new({
          :cites_appendices => ['nc']
        })
        @taxon_concepts = @checklist.taxon_concepts_rel
      end
      it "should not return Cacatua goffiniana" do
        @taxon_concepts.select{ |e| e.full_name == @species1_2_1.full_name }.first.should be_nil
      end

      it "should return Agapornis roseicollis" do
        @taxon_concepts.select{ |e| e.full_name == @species2_1.full_name }.first.should_not be_nil
      end
    end

    context "I, NC" do
      before(:all) do
        @checklist = Checklist.new({
          :cites_appendices => ['I','nc']
        })
        @taxon_concepts = @checklist.taxon_concepts_rel
      end
      it "should return Cacatua goffiniana" do
        @taxon_concepts.select{ |e| e.full_name == @species1_2_1.full_name }.first.should_not be_nil
      end

      it "should return Agapornis roseicollis" do
        @taxon_concepts.select{ |e| e.full_name == @species2_1.full_name }.first.should_not be_nil
      end
    end

  end
end