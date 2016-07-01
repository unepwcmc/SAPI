require 'spec_helper'

describe Checklist do
  include_context "Arctocephalus"

  context "when common names displayed" do
    before(:all) do
      @checklist = Checklist::Checklist.new({
        :output_layout => :alphabetical,
        :show_english => '1',
        :show_spanish => '1',
        :show_french => '1'
      })
      @taxon_concepts = @checklist.results
      @australis = @taxon_concepts.select { |e| e.full_name == @species1.full_name }.first
      @arctocephalus = @taxon_concepts.select { |e| e.full_name == @genus.full_name }.first
    end

    it "should return all English names for Arctocephalus australis: 'South American Fur Seal, Southern Fur Seal'" do
      @australis.english_names.should == ['South American Fur Seal', 'Southern Fur Seal']
    end

    it "should return all Spanish names for Arctocephalus australis: 'Lobo fino sudamericano, Oso marino austral'" do
      @australis.spanish_names.should == ['Lobo fino sudamericano', 'Oso marino austral']
    end

    it "should return all French names for Arctocephalus australis: 'Otarie à fourrure australe'" do
      @australis.french_names.should == ['Otarie à fourrure australe']
    end

    it "should return all English names for Arctocephalus spp.: 'Fur seals, Southern fur seals'" do
      @arctocephalus.english_names.should == ['Fur seals 1', 'Southern fur seals']
    end

    it "should return all Spanish names for Arctocephalus spp.: 'Osos marinos'" do
      @arctocephalus.spanish_names.should == ['Osos marinos']
    end

    it "should return all French names for Arctocephalus spp.: 'Arctocéphales du sud, Otaries à fourrure, Otaries à fourrure du sud'" do
      @arctocephalus.french_names.should == ['Arctocéphales du sud', 'Otaries à fourrure', 'Otaries à fourrure du sud']
    end

    it "should include a species without any common names defined" do
      @pusillus = @taxon_concepts.select { |e| e.full_name == @species3.full_name }.first
      @pusillus.should_not be_nil
    end

  end

end
