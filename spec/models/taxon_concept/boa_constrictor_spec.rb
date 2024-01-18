require 'spec_helper'

describe TaxonConcept do
  context "Boa constrictor" do
    include_context "Boa constrictor"
    context "TAXONOMY" do
      describe :full_name do
        context "for subspecies Boa constrictor occidentalis" do
          specify { expect(@subspecies1.full_name).to eq('Boa constrictor occidentalis') }
        end
        context "for species Boa constrictor" do
          specify { expect(@species.full_name).to eq('Boa constrictor') }
        end
        context "for genus Boa" do
          specify { expect(@genus.full_name).to eq('Boa') }
        end
      end

      describe :ancestors do
        context "family" do
          specify { expect(@species.family_name).to eq('Boidae') }
        end
        context "order" do
          specify { expect(@species.order_name).to eq('Serpentes') }
        end
        context "class" do
          specify { expect(@species.class_name).to eq('Reptilia') }
        end
      end
    end

    context "LISTING" do
      describe :cites_listing do
        context "for subspecies Boa constrictor occidentalis" do
          specify { expect(@subspecies1.cites_listing).to eq('I') }
        end
        context "for subspecies Boa constrictor constrictor" do
          specify { expect(@subspecies2.cites_listing).to eq('II') }
        end
        context "for species Boa constrictor" do
          specify { expect(@species.cites_listing).to eq('I/II') }
        end
      end

      describe :eu_listing do
        context "for subspecies Boa constrictor occidentalis" do
          specify { expect(@subspecies1.eu_listing).to eq('A') }
        end
        context "for subspecies Boa constrictor constrictor" do
          specify { expect(@subspecies2.eu_listing).to eq('B') }
        end
        context "for species Boa constrictor" do
          specify { expect(@species.eu_listing).to eq('A/B') }
        end
      end

      describe :cites_listed do
        context "for family Boidae" do
          specify { expect(@family.cites_listed).to be_truthy }
        end
        context "for genus Boa" do
          specify { expect(@genus.cites_listed).to eq(false) }
        end
        context "for species Boa constrictor (inclusion in higher taxa listing)" do
          specify { expect(@species.cites_listed).to eq(false) }
        end
        context "for subspecies Boa constrictor occidentalis" do
          specify { expect(@subspecies1.cites_listed).to be_truthy }
        end
        context "for subspecies Boa constrictor constrictor" do
          specify { expect(@subspecies2.cites_listed).to be_falsey }
        end
      end

      describe :cites_show do
        context "for family Boidae" do
          specify { expect(@family.cites_show).to be_truthy }
        end
        context "for genus Boa" do
          specify { expect(@genus.cites_show).to be_truthy }
        end
        context "for species Boa constrictor (inclusion in higher taxa listing)" do
          specify { expect(@species.cites_show).to be_truthy }
        end
        context "for subspecies Boa constrictor occidentalis" do
          specify { expect(@subspecies1.cites_show).to be_truthy }
        end
        context "for subspecies Boa constrictor constrictor" do
          specify { expect(@subspecies2.cites_show).to be_falsey }
        end
      end

      describe :cites_listed_descendants do
        context "for family Boidae" do
          specify { expect(@family.cites_listed_descendants).to be_truthy }
        end
        context "for genus Boa" do
          specify { expect(@genus.cites_listed_descendants).to be_truthy }
        end
        context "for species Boa constrictor (inclusion in higher taxa listing)" do
          specify { expect(@species.cites_listed_descendants).to be_truthy }
        end
        context "for subspecies Boa constrictor occidentalis" do
          specify { expect(@subspecies1.cites_listed_descendants).to be_falsey }
        end
      end

      describe :eu_listed do
        context "for family Boidae" do
          specify { expect(@family.eu_listed).to be_truthy }
        end
        context "for genus Boa" do
          specify { expect(@genus.eu_listed).to eq(false) }
        end
        context "for species Boa constrictor (inclusion in higher taxa listing)" do
          specify { expect(@species.eu_listed).to eq(false) }
        end
        context "for subspecies Boa constrictor occidentalis" do
          specify { expect(@subspecies1.eu_listed).to be_truthy }
        end
      end

      describe :show_in_species_plus_ac do
        context "for family Boidae" do
          specify { expect(@family_ac.show_in_species_plus_ac).to be_truthy }
        end
        context "for genus Boa" do
          specify { expect(@genus_ac.show_in_species_plus_ac).to be_truthy }
        end
        context "for species Boa constrictor (inclusion in higher taxa listing)" do
          specify { expect(@species_ac.show_in_species_plus_ac).to be_truthy }
        end
        context "for subspecies Boa constrictor occidentalis" do
          specify { expect(@subspecies1_ac.show_in_species_plus_ac).to be_truthy }
        end
        context "for subspecies Boa constrictor constrictor" do
          specify { expect(@subspecies2_ac.show_in_species_plus_ac).to be_falsey }
        end
      end

      describe :show_in_checklist_ac do
        context "for family Boidae" do
          specify { expect(@family_ac.show_in_checklist_ac).to be_truthy }
        end
        context "for genus Boa" do
          specify { expect(@genus_ac.show_in_checklist_ac).to be_truthy }
        end
        context "for species Boa constrictor (inclusion in higher taxa listing)" do
          specify { expect(@species_ac.show_in_checklist_ac).to be_truthy }
        end
        context "for subspecies Boa constrictor occidentalis" do
          specify { expect(@subspecies1_ac.show_in_checklist_ac).to be_truthy }
        end
        context "for subspecies Boa constrictor constrictor" do
          specify { expect(@subspecies2_ac.show_in_checklist_ac).to be_falsey }
        end
      end

    end

  end
end
