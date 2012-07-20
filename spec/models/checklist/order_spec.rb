require 'spec_helper'

describe Checklist do
  include_context "Tapiridae"
  include_context "Psittaciformes"
  include_context "Falconiformes"

  context "when taxonomic order" do
    before(:all) do
      Sapi::rebuild()
      @checklist = Checklist.new({:output_layout => :taxonomic})
      @taxon_concepts = @checklist.taxon_concepts_rel
    end
    it "should include phyla in specific order (Chordata, Echinodermata, ...)" do
      indexes = []
      %w(
        Chordata
        Echinodermata
        Arthropoda
        Annelida
        Mollusca
        Cnidaria
      ).each do |t|
        indexes<< @taxon_concepts.index{ |tc| tc.full_name == t }
      end
      indexes.should == indexes.sort
    end
    it "should include classes in specific order (Mammalia, Aves, ...)" do
      indexes = []
      %w(
        Mammalia
        Aves
        Reptilia
        Amphibia
        Elasmobranchii
        Actinopterygii
        Sarcopterygii
        Holothuroidea
        Arachnida
        Insecta
        Hirudinoidea
        Bivalvia
        Gastropoda
        Anthozoa
        Hydrozoa

      ).each do |t|
        indexes<< @taxon_concepts.index{ |tc| tc.full_name == t }
      end
      indexes.should == indexes.sort
    end
    it "should include Perissodactyla within Mammalia" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Perissodactyla' }.should >
        @taxon_concepts.index{ |tc| tc.full_name == 'Mammalia' }
      @taxon_concepts.index{ |tc| tc.full_name == 'Perissodactyla' }.should <
        @taxon_concepts.index{ |tc| tc.full_name == 'Aves' }
    end
    it "should include Perissodactyla (Mammalia) before Falconiformes (Aves)" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Perissodactyla' }.should <
        @taxon_concepts.index{ |tc| tc.full_name == 'Falconiformes' }
    end
    it "should include Falconiformes (Aves) before Psittaciformes (Aves)" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Falconiformes' }.should <
        @taxon_concepts.index{ |tc| tc.full_name == 'Psittaciformes' }
    end
    it "should include Cathartidae within Falconiformes" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should >
        @taxon_concepts.index{ |tc| tc.full_name == 'Falconiformes' }
      @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should <
        @taxon_concepts.index{ |tc| tc.full_name == 'Psittaciformes' }
    end
    it "should include Cathartidae (Falconiformes) before Falconidae (Falconiformes)" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should <
        @taxon_concepts.index{ |tc| tc.full_name == 'Falconidae' }
    end
    it "should include Cathartidae (Falconiformes) before Cacatuidae (Psittaciformes)" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should <
        @taxon_concepts.index{ |tc| tc.full_name == 'Cacatuidae' }
    end
  end
  context "when alphabetical order" do
    before(:all) do
      @checklist = Checklist.new({:output_layout => :alphabetical})
      @taxon_concepts = @checklist.taxon_concepts_rel
    end
    it "should not include phyla" do
      @taxon_concepts.index{ |tc| tc.rank == 'PHYLUM'}.should be_nil
    end
    it "should not include classes" do
      @taxon_concepts.index{ |tc| tc.rank == 'CLASS'}.should be_nil
    end
    it "should include Perissodactyla (Mammalia) after Falconiformes (Aves)" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Perissodactyla' }.should >
        @taxon_concepts.index{ |tc| tc.full_name == 'Falconiformes' }
    end
    it "should include Falconiformes (Aves) before Psittaciformes (Aves)" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Falconiformes' }.should <
        @taxon_concepts.index{ |tc| tc.full_name == 'Psittaciformes' }
    end
    it "should include Cathartidae before Falconiformes" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should <
        @taxon_concepts.index{ |tc| tc.full_name == 'Falconiformes' }
    end
    it "should include Cathartidae (Falconiformes) before Falconidae (Falconiformes)" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should <
        @taxon_concepts.index{ |tc| tc.full_name == 'Falconidae' }
    end
    it "should include Cathartidae (Falconiformes) after Cacatuidae (Psittaciformes)" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should >
        @taxon_concepts.index{ |tc| tc.full_name == 'Cacatuidae' }
    end
  end
end