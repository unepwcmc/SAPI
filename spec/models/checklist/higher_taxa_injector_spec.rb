require 'spec_helper'

describe Checklist::HigherTaxaInjector do
  before do
    kingdom = create_cites_eu_kingdom(
      :taxon_name => create(:taxon_name, :scientific_name => 'Testae'),
      :taxonomic_position => '1'
    )
    phylum = create_cites_eu_phylum(
      :parent => kingdom,
      :taxon_name => create(:taxon_name, :scientific_name => 'Rotflata'),
      :taxonomic_position => '1.1'
    )
    klass = create_cites_eu_class(
      :parent => phylum,
      :taxon_name => create(:taxon_name, :scientific_name => 'Forfiteria'),
      :taxonomic_position => '1.1.1'
    )
    order1 = create_cites_eu_order(
      :parent => klass,
      :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatiformes')
    )
    family1 = create_cites_eu_family(
      :parent => order1,
      :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatidae')
    )
    genus1_1 = create_cites_eu_genus(
      :parent => family1,
      :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatus')
    )
    species1_1_1 = create_cites_eu_species(
      :parent => genus1_1,
      :taxon_name => create(:taxon_name, :scientific_name => 'lolus')
    )
    subspecies1_1_1_1 = create_cites_eu_subspecies(
      :parent => species1_1_1,
      :taxon_name => create(:taxon_name, :scientific_name => 'cracovianus')
    )
    species1_1_2 = create_cites_eu_species(
      :parent => genus1_1,
      :taxon_name => create(:taxon_name, :scientific_name => 'ridiculus')
    )
    genus1_2 = create_cites_eu_genus(
      :parent => family1,
      :taxon_name => create(:taxon_name, :scientific_name => 'Lollipopus')
    )
    species1_2_1 = create_cites_eu_species(
      :parent => genus1_2,
      :taxon_name => create(:taxon_name, :scientific_name => 'lolus')
    )
    species1_2_2 = create_cites_eu_species(
      :parent => genus1_2,
      :taxon_name => create(:taxon_name, :scientific_name => 'ridiculus')
    )
    family2 = create_cites_eu_family(
      :parent => order1,
      :taxon_name => create(:taxon_name, :scientific_name => 'Foobaridae')
    )
    genus2_1 = create_cites_eu_genus(
      :parent => family2,
      :taxon_name => create(:taxon_name, :scientific_name => 'Foobarus')
    )
    species2_1_1 = create_cites_eu_species(
      :parent => genus2_1,
      :taxon_name => create(:taxon_name, :scientific_name => 'lolus')
    )
    species2_1_2 = create_cites_eu_species(
      :parent => genus2_1,
      :taxon_name => create(:taxon_name, :scientific_name => 'ridiculus')
    )
    order2 = create_cites_eu_order(
      :parent => klass,
      :taxon_name => create(:taxon_name, :scientific_name => 'Testariformes')
    )
    klass2 = create_cites_eu_class(
      :parent => phylum,
      :taxon_name => create(:taxon_name, :scientific_name => 'Memaria'),
      :taxonomic_position => '1.1.2'
    )
    order2_1 = create_cites_eu_order(
      :parent => klass2,
      :taxon_name => create(:taxon_name, :scientific_name => 'Memariformes')
    )
    family2_1_1 = create_cites_eu_family(
      :parent => order2_1,
      :taxon_name => create(:taxon_name, :scientific_name => 'Memaridae')
    )
    genus2_1_1_1 = create_cites_eu_genus(
      :parent => family2_1_1,
      :taxon_name => create(:taxon_name, :scientific_name => 'Zonker')
    )
    species2_1_1_1_1 = create_cites_eu_species(
      :parent => genus2_1_1_1,
      :taxon_name => create(:taxon_name, :scientific_name => 'fatalus')
    )
    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    @order2 = MTaxonConcept.find(order2.id)
    @family1 = MTaxonConcept.find(family1.id)
    @genus1_1 = MTaxonConcept.find(genus1_1.id)
    @species1_1_1 = MTaxonConcept.find(species1_1_1.id)
    @subspecies1_1_1_1 = MTaxonConcept.find(subspecies1_1_1_1.id)
    @species1_1_2 = MTaxonConcept.find(species1_1_2.id)
    @species1_2_1 = MTaxonConcept.find(species1_2_1.id)
    @family2 = MTaxonConcept.find(family2.id)
    @genus2_1 = MTaxonConcept.find(genus2_1.id)
    @species2_1_1 = MTaxonConcept.find(species2_1_1.id)
    @species2_1_1_1_1 = MTaxonConcept.find(species2_1_1_1_1.id)
  end

  describe :run do
    context "when same phylum" do

      context "when two species from different classes" do
        let(:hti_different_class) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_1,
              @species2_1_1_1_1
            ]
            )
        }
        specify {
          headers = hti_different_class.higher_taxa_headers(
            @species1_1_1,
            @species2_1_1_1_1
            )
          headers.map(&:full_name).should == ['Memaridae']
        }
      end
      context "when two species from different classes and expand_headers set" do
        let(:hti_different_class) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_1,
              @species2_1_1_1_1
            ], { :expand_headers => true }
          )
        }
        specify {
          headers = hti_different_class.higher_taxa_headers(
            @species1_1_1,
            @species2_1_1_1_1
            )
          headers.map(&:full_name).should == ['Memaria', 'Memariformes', 'Memaridae']
        }
      end
    end
    context "when same order" do
      context "when two species from different families" do
        let(:hti_different_family) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_1,
              @species2_1_1
            ]
            )
        }
        specify {
          hti_different_family.run.size.should == 4
        }
      end
      context "when two species from different families and skip family set" do
        let(:hti_different_family) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_1,
              @species2_1_1
            ], { :skip_ancestor_ids => [@family1.id] }
          )
        }
        specify {
          hti_different_family.run.size.should == 3
        }
      end
    end
  end

  describe :higher_taxa_headers do
    context "when same genus" do
      context "when one species" do
        let(:hti_one_species) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_1
            ]
            )
        }
        specify {
          headers = hti_one_species.higher_taxa_headers(nil, @species1_1_1)
          headers.map(&:full_name).should == ['Lolcatidae']
        }
      end
      context "when one species and skip family set" do
        let(:hti_one_species_skip_family) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_1
            ], { :skip_ancestor_ids => [@family1.id] }
          )
        }
        specify {
          hti_one_species_skip_family.higher_taxa_headers(nil, @species1_1_1).should be_empty
        }
      end
      context "when one species and expand headers set" do
        let(:hti_one_species_expand_headers) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_1
            ], { :expand_headers => true }
          )
        }
        specify {
          headers = hti_one_species_expand_headers.higher_taxa_headers(nil, @species1_1_1)
          headers.map(&:full_name).should ==
          ["Rotflata", "Forfiteria", "Lolcatiformes", "Lolcatidae"]
        }
      end
      context "when two species" do
        let(:hti_same_genus) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_1,
              @species1_1_2
            ]
            )
        }
        specify {
          hti_same_genus.higher_taxa_headers(@species1_1_1, @species1_1_2).should be_empty
        }
      end
      context "when species and subspecies" do
        let(:hti_species_subspecies) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_2,
              @subspecies1_1_1_1
            ]
            )
        }
        specify {
          hti_species_subspecies.higher_taxa_headers(@species1_1_2, @subspecies1_1_1_1).should be_empty
        }
      end
    end
    context "when same family" do
      context "when two species from different genera" do
        let(:hti_same_family) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_1,
              @species1_2_1
            ]
            )
        }
        specify {
          hti_same_family.higher_taxa_headers(@species1_1_1, @species1_2_1).should be_empty
        }
      end
    end
    context "when same order" do
      context "when two species from different families" do
        let(:hti_different_family) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_1,
              @species2_1_1
            ]
            )
        }
        specify {
          headers = hti_different_family.higher_taxa_headers(@species1_1_1, @species2_1_1)
          headers.map(&:full_name).should ==
          ['Foobaridae']
        }
      end
      context "when two species from different families and expand headers set" do
        let(:hti_different_family) {
          Checklist::HigherTaxaInjector.new(
            [
              @species1_1_1,
              @species2_1_1
            ], { :expand_headers => true }
          )
        }
        specify {
          headers = hti_different_family.higher_taxa_headers(@species1_1_1, @species2_1_1)
          headers.map(&:full_name).should ==
          ['Foobaridae']
        }
      end
      context "when genus and different family" do
        let(:hti_genus_family) {
          Checklist::HigherTaxaInjector.new(
            [
              @genus1_1,
              @family2
            ]
            )
        }
        specify {
          headers = hti_genus_family.higher_taxa_headers(@genus1_1, @family2)
          headers.map(&:full_name).should ==
          ['Foobaridae']
        }
      end
      context "when family and genus in different family" do
        let(:hti_family_genus) {
          Checklist::HigherTaxaInjector.new(
            [
              @family1,
              @genus2_1
            ]
            )
        }
        specify {
          headers = hti_family_genus.higher_taxa_headers(@family1, @genus2_1)
          headers.map(&:full_name).should ==
          ['Foobaridae']
        }
      end
    end
    context "when same class" do
      context "when order and genus from different order" do
        let(:hti_different_orders) {
          Checklist::HigherTaxaInjector.new(
            [
              @order2,
              @genus2_1
            ]
            )
        }
        specify {
          headers = hti_different_orders.higher_taxa_headers(@order2, @genus2_1)
          headers.map(&:full_name).should ==
          ['Foobaridae']
        }
      end
      context "when order and genus from different order and expand headers set" do
        let(:hti_different_orders_expand) {
          Checklist::HigherTaxaInjector.new(
            [
              @order2,
              @genus2_1
            ], { :expand_headers => true }
          )
        }
        specify {
          headers = hti_different_orders_expand.higher_taxa_headers(@order2, @genus2_1)
          headers.map(&:full_name).should ==
          ['Lolcatiformes', 'Foobaridae']
        }
      end
    end
  end
end
