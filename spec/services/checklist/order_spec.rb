require 'spec_helper'

describe Checklist do
  include_context "Tapiridae"
  include_context "Psittaciformes"
  include_context "Falconiformes"
  include_context "Hirudo medicinalis"
  include_context "Panax ginseng"
  include_context "Agave"
  context "when taxonomic order" do
    context("Plantae") do
      before(:all) do
        @checklist = Checklist::Checklist.new({ :output_layout => :taxonomic, :per_page => 100 })
        @checklist.generate
        @taxon_concepts = @checklist.plantae
      end
      it "should include Agave (Agavaceae) before Panax (Araliaceae)" do
        expect(@taxon_concepts.index { |tc| tc.full_name == 'Agave parviflora' }).to be <
          @taxon_concepts.index { |tc| tc.full_name == 'Panax ginseng' }
      end
    end
    context("Animalia") do
      before(:all) do
        @checklist = Checklist::Checklist.new({ :output_layout => :taxonomic, :per_page => 100 })
        @checklist.generate
        @taxon_concepts = @checklist.animalia
      end
      it "should include birds after last mammal" do
        expect(@taxon_concepts.index { |tc| tc.full_name == 'Tapirus terrestris' }).to be <
          @taxon_concepts.index { |tc| tc.full_name == 'Gymnogyps californianus' }
      end
      it "should include Falconiformes (Aves) before Psittaciformes (Aves)" do
        expect(@taxon_concepts.index { |tc| tc.full_name == 'Falconiformes' }).to be <
          @taxon_concepts.index { |tc| tc.full_name == 'Psittaciformes' }
      end
      it "should include Cathartidae within Falconiformes" do
        expect(@taxon_concepts.index { |tc| tc.full_name == 'Cathartidae' }).to be >
          @taxon_concepts.index { |tc| tc.full_name == 'Falconiformes' }
        expect(@taxon_concepts.index { |tc| tc.full_name == 'Cathartidae' }).to be <
          @taxon_concepts.index { |tc| tc.full_name == 'Psittaciformes' }
      end
      it "should include Cathartidae (Falconiformes) before Falconidae (Falconiformes)" do
        expect(@taxon_concepts.index { |tc| tc.full_name == 'Cathartidae' }).to be <
          @taxon_concepts.index { |tc| tc.full_name == 'Falconidae' }
      end
      it "should include Cathartidae (Falconiformes) before Cacatuidae (Psittaciformes)" do
        expect(@taxon_concepts.index { |tc| tc.full_name == 'Cathartidae' }).to be <
          @taxon_concepts.index { |tc| tc.full_name == 'Cacatuidae' }
      end
      it "should include Hirudo medicinalis at the very end (after all Chordata)" do
        expect(@taxon_concepts.index { |tc| tc.full_name == 'Hirudo medicinalis' }).to eq(
          @taxon_concepts.length - 1
        )
      end
    end
  end
  context "when alphabetical order" do
    before(:all) do
      @checklist = Checklist::Checklist.new({ :output_layout => :alphabetical, :per_page => 100 })
      @taxon_concepts = @checklist.results
    end
    it "should include Falconiformes (Aves) before Psittaciformes (Aves)" do
      expect(@taxon_concepts.index { |tc| tc.full_name == 'Falconiformes' }).to be <
        @taxon_concepts.index { |tc| tc.full_name == 'Psittaciformes' }
    end
    it "should include Cathartidae before Falconiformes" do
      expect(@taxon_concepts.index { |tc| tc.full_name == 'Cathartidae' }).to be <
        @taxon_concepts.index { |tc| tc.full_name == 'Falconiformes' }
    end
    it "should include Cathartidae (Falconiformes) before Falconidae (Falconiformes)" do
      expect(@taxon_concepts.index { |tc| tc.full_name == 'Cathartidae' }).to be <
        @taxon_concepts.index { |tc| tc.full_name == 'Falconidae' }
    end
    it "should include Cathartidae (Falconiformes) after Cacatuidae (Psittaciformes)" do
      expect(@taxon_concepts.index { |tc| tc.full_name == 'Cathartidae' }).to be >
        @taxon_concepts.index { |tc| tc.full_name == 'Cacatuidae' }
    end
  end
end
